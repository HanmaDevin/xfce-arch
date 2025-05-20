#! /bin/bash
#    ____           __        ____   _____           _       __ 
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_  
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/  
#                                                  /_/           
clear

location="$HOME/xfce-arch"

installPackages() {
    sudo pacman --noconfirm -S $(cat "$location/packages.txt")
}

installAurPackages() {
    yay --noconfirm -S $(cat "$location/aur_packages.txt")
}

installYay() {
    installPackages "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    git clone https://aur.archlinux.org/yay.git $HOME/.yay
    cd $HOME/$repo/yay
    makepkg -si
    cd $temp_path
    echo ":: yay has been installed successfully."
}

config_ufw() {
  gum spin --spinner dot --title "Firewall will be configured..." -- sleep 2
  sudo ufw enable
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw status verbose
}

copy_config() {
  gum spin --spinner dot --title "Creating bakups..." -- sleep 2

  if [[ -f "$HOME/.zshrc" ]]; then 
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  if [[ -d "$HOME/.config" ]]; then 
    mv "$HOME/.config" "$HOME/.config.bak"
  fi
  cp -r "$location/.config/" "$HOME/"
  cp -r "$location/Wallpaper" "$HOME/Pictures/"
  cp "$location/.zshrc" "$HOME/"

  sudo cp "$location/etc/pacman.conf" "/etc/"

  sudo cp -r "$location/icons/" "/usr/share/"
  sudo cp -r "$location/themes/" "/usr/share/"
}

configure_git() {
  echo "Want to configure git?"
  gitconfig=$(gum choose "Yes" "No")
  if [[ "$gitconfig" == "Yes" ]]; then
  
    username=$(gum input --prompt "> What is your github user name?")
    git config --global user.name "$username"
    useremail=$(gum input --prompt "> What is your github email?")
    git config --global user.email "$useremail"
    git config --global pull.rebase true
  fi
  
  echo "Want to create a ssh-key?"
  ssh=$(gum choose "Yes" "No")
  if [[ "$ssh" == "Yes" ]]; then
    ssh-keygen -t ed25519 -C "$useremail"
  fi

  echo "Want to create a physical key?"
  key=$(gum choose "Yes" "No")
  if [[ $key == "Yes" ]]; then
    read -r -p "Insert a device like a YubiKey and press enter..." 
    ssh-keygen -t ecdsa-sk -b 521
  fi
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "Xfce Setup"
echo -e "${NONE}"

sudo pacman -Syu

installPackages

installYay

installAurPackages

gum spin --spinner dot --title "Starting setup now..." -- sleep 2
copy_config
configure_git
config_ufw

chsh -s /bin/zsh 

systemctl enable bluetooth.service
systemctl start bluetooth.service
systemctl enable NetworkManager.service
systemctl start NetworkManager.service

curl -o- https://fnm.vercel.app/install | bash

echo -e "${MAGENTA}"
cat <<"EOF"
    ____  __                        ____       __                __ 
   / __ \/ /__  ____ _________     / __ \___  / /_  ____  ____  / /_
  / /_/ / / _ \/ __ `/ ___/ _ \   / /_/ / _ \/ __ \/ __ \/ __ \/ __/
 / ____/ /  __/ /_/ (__  )  __/  / _, _/  __/ /_/ / /_/ / /_/ / /_  
/_/   /_/\___/\__,_/____/\___/  /_/ |_|\___/_.___/\____/\____/\__/  
EOF
echo -e "${NONE}"
