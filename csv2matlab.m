clear all
clc

%% import data to matlab variables
% status
batt        = csvread('current_battery_status_0.csv',1,0);
sys_power   = csvread('current_system_power_0.csv',1,0);
gps_status  = csvread('current_vehicle_gps_position_0.csv',1,0);

% sensor
imu_raw     = csvread('current_sensor_combined_0.csv',1,0);
baro        = csvread('current_vehicle_air_data_0.csv',1,0);
att         = csvread('current_vehicle_attitude_0.csv',1,0);
glo_pos     = csvread('current_vehicle_global_position_0.csv',1,0);
loc_pos     = csvread('current_vehicle_local_position_0.csv',1,0);
mag         = csvread('current_vehicle_magnetometer_0.csv',1,0);
ekf         = csvread('current_ekf2_innovations_0.csv',1,0);

% reference/input
rc_input    = csvread('current_input_rc_0.csv',1,0);
manual_ref  = csvread('current_manual_control_setpoint_0.csv',1,0);
att_ref     = csvread('current_vehicle_attitude_setpoint_0.csv',1,0);
loc_pos_ref = csvread('current_vehicle_local_position_setpoint_0.csv',1,0);

% control 
rate_ctrl   = csvread('current_rate_ctrl_status_0.csv',1,0);
act_ctrl    = csvread('current_actuator_controls_0_0.csv',1,0);
act_out     = csvread('current_actuator_outputs_0.csv',1,0);

save('current')

%% parse all log file
load('current')

t_begin = min([batt(1),sys_power(1),gps_status(1),imu_raw(1),...
    baro(1),att(1),glo_pos(1),loc_pos(1),mag(1),ekf(1),rc_input(1),...
    manual_ref(1),att_ref(1),loc_pos_ref(1),rate_ctrl(1),act_ctrl(1),act_out(1)]);
% status
st_b_t      = (batt(:,1)-t_begin)/1000000;
st_b_v      = batt(:,2);            % voltage of battery
st_b_fil_v  = batt(:,3);            % filtered voltage of battery
st_b_a      = batt(:,4);            % current
st_b_fil_a  = batt(:,5);            % filtered current
st_b_c      = batt(:,7);            % mAh output

st_p_t      = (sys_power(:,1)-t_begin)/1000000;
st_p_v      = sys_power(:,2);       % voltage of pixhawk

st_g_t      = (gps_status(:,1)-t_begin)/1000000;
st_g_fix    = gps_status(:,21);     % 3 is fixed
st_g_sat    = gps_status(:,23);     % number of satellites locked

% sensor
ss_raw_t    = (imu_raw(:,1)-t_begin)/1000000;
ss_raw_gyx  = imu_raw(:,2);         % x gyro reading
ss_raw_gyy  = imu_raw(:,3);         % y gyro reading
ss_raw_gyz  = imu_raw(:,4);         % z gyro reading
ss_raw_gydt = imu_raw(:,5);         % gyro integration time dt
ss_raw_acx  = imu_raw(:,7);         % x acc reading
ss_raw_acy  = imu_raw(:,8);         % y acc reading
ss_raw_acz  = imu_raw(:,9);         % z acc reading
ss_raw_acdt = imu_raw(:,10);        % acc integration time dt

ss_b_t      = (baro(:,1)-t_begin)/1000000;
ss_b_alt    = baro(:,2);            % baro altitude (m)
ss_b_temp   = baro(:,3);            % baro temperature (celcius)
ss_b_pres   = baro(:,4);            % baro pressure (Pa)
ss_b_rho    = baro(:,5);            % air density, rho

ss_att_t    = (att(:,1)-t_begin)/1000000;
ss_att_p    = att(:,2);             % roll speed (rad/s)
ss_att_q    = att(:,3);             % pitch speed (rad/s)
ss_att_r    = att(:,4);             % yaw speed (rad/s)
ss_att_q0   = att(:,5);             % quatenion q0
ss_att_q1   = att(:,6);             % quatenion q1
ss_att_q2   = att(:,7);             % quatenion q2
ss_att_q3   = att(:,8);             % quatenion q3
eul         = quat2eul([ss_att_q0 ss_att_q1 ss_att_q2 ss_att_q3]);
ss_att_psi  = eul(:,1);             % yaw angle (rad)
ss_att_tht  = eul(:,2);             % pitch angle (rad)
ss_att_phi  = eul(:,3);             % roll angle (rad)

ss_pos_t    = (loc_pos(:,1)-t_begin)/1000000;
ss_pos_xb   = loc_pos(:,5);         % body frame xb (m)
ss_pos_yb   = loc_pos(:,6);         % body frame yb (m)
ss_pos_zb   = loc_pos(:,7);         % body frame zb (m)
ss_pos_ub   = loc_pos(:,11);        % body frame ub (m/s)
ss_pos_vb   = loc_pos(:,12);        % body frame vb (m/s)
ss_pos_wb   = loc_pos(:,13);        % body frame wb (m/s)

% reference
sp_pos_t    = (loc_pos_ref(:,1)-t_begin)/1000000;
sp_pos_xb   = loc_pos_ref(:,2);     % body frame xb (m)
sp_pos_yb   = loc_pos_ref(:,3);     % body frame yb (m)
sp_pos_zb   = loc_pos_ref(:,4);     % body frame zb (m)
sp_pos_ub   = loc_pos_ref(:,7);     % body frame ub (m/s)
sp_pos_vb   = loc_pos_ref(:,8);     % body frame vb (m/s)
sp_pos_wb   = loc_pos_ref(:,9);     % body frame wb (m/s)

sp_att_t    = (att_ref(:,1)-t_begin)/1000000;
sp_att_psi  = att_ref(:,4);         % yaw angle (rad)
sp_att_tht  = att_ref(:,3);         % pitch angle (rad)
sp_att_phi  = att_ref(:,2);         % roll angle (rad)


%% plot
figure (1)
plot3(ss_pos_xb,ss_pos_yb,-ss_pos_zb,'b')
grid on
hold on
plot3(sp_pos_xb,sp_pos_yb,-sp_pos_zb,'r--')
legend('Actual flight','Trajectory reference')
axis equal
ylim([-10 10])
xlim([-30 10])
xlabel('meter')
hold off

%% plot
figure (2)
subplot(2,1,1)
plot(ss_pos_t, ss_pos_xb, 'b',sp_pos_t, sp_pos_xb, 'r--');
xlim([10 25])
ylabel('x-position (m)')
legend('Actual response','Reference')
subplot(2,1,2)
plot(ss_pos_t, ss_pos_yb, 'b',sp_pos_t, sp_pos_yb, 'r--');
xlim([10 25])
ylabel('y-position (m)')
xlabel('Time (s)')

%% plot
figure (3)
subplot(2,1,1)
plot(ss_pos_t, ss_pos_ub, 'b',sp_pos_t, sp_pos_ub, 'r--');
xlim([5 35])
ylabel('x-velocity (m)')
legend('Actual response','Reference')
subplot(2,1,2)
plot(ss_pos_t, ss_pos_vb, 'b',sp_pos_t, sp_pos_vb, 'r--');
xlim([5 35])
ylabel('y-velocity (m)')
xlabel('Time (s)')


%% plot
figure (4)
subplot(3,1,1)
plot(ss_att_t, ss_att_phi, 'b',sp_att_t, sp_att_phi, 'r--');
xlim([5 35])
ylabel('Roll angle (rad)')
legend('Actual response','Reference')
subplot(3,1,2)
plot(ss_att_t, ss_att_tht, 'b',sp_att_t, sp_att_tht, 'r--');
xlim([5 35])
ylabel('Pitch angle (rad)')
subplot(3,1,3)
plot(ss_att_t, ss_att_psi, 'b',sp_att_t, sp_att_psi, 'r--');
xlim([5 35])
ylabel('Yaw angle (rad)')
xlabel('Time (s)')
