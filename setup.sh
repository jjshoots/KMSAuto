# create some default directories
mkdir Sandboxes
mkdir System
mkdir AppImages

# update the software
sudo apt update
sudo apt -y upgrade

# install gnome tweaks
sudo apt install gnome-tweaks --yes

# install git
sudo apt install git --yes

# install trash cli
sudo apt install trash-cli --yes

# install thermal sensors
sudo apt install lm-sensors psensor hddtemp --yes

# install fish
sudo apt install fish --yes
fish
sudo chsh -s /usr/bin/fish
mkdir -p ~/.config/fish
echo "set -g -x fish_greeting ''" >> ~/.config/fish/config.fish
echo "alias tp=trash-put" >> ~/.config/fish/config.fish
echo "alias rm='echo "this is not the command you are looking for, use tp instead"'" >> ~/.config/fish/config.fish

# install neovim
sudo apt install neovim nodejs npm --yes
sudo npm install -g n
sudo n stable

# neovim setup plugins and coc
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
cd ~/.config/
git clone https://github.com/jjshoots/nvim_dotfiles.git --yes
nvim +PlugInstall +qall
nvim +'CocInstall coc-pyright coc-clangd coc-html coc-json coc-cmake coc-smartf' +qall

# install python3, pip3, and common modules
sudo apt install python3 python3-pip --yes
pip3 install torch torchvision torchaudio
pip3 install numpy matplotlib pyyaml

# nerdfonts install
cd ~/System/
git clone https://github.com/ryanoasis/nerd-fonts --depth 1
cd nerd-fonts
sudo ./install.sh Mononoki
