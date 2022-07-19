#!/usr/bin/env bash
#
#
#
# User customizations and AUR package installation.
echo -ne "
-------------------------------------------------------------------------
    _         _          _             _     _     _
   / \  _   _| |_ ___   / \   _ __ ___| |__ | |   (_)_ __  _   ___  __
  / _ \| | | | __/ _ \ / _ \ | '__/ __| '_ \| |   | | '_ \| | | \ \/ /
 / ___ \ |_| | || (_) / ___ \| | | (__| | | | |___| | | | | |_| |>  <
/_/   \_\__,_|\__\___/_/   \_\_|  \___|_| |_|_____|_|_| |_|\__,_/_/\_\
-------------------------------------------------------------------------
                    Auto Arch Linux Install
-------------------------------------------------------------------------

Installing AUR Softwares
"
source $HOME/ArchTitus/configs/setup.conf

: <<'EOT'
  cd ~
  mkdir "/home/$USERNAME/.cache"
  touch "/home/$USERNAME/.cache/zshhistory"
  git clone "https://github.com/ChrisTitusTech/zsh"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  ln -s "~/zsh/.zshrc" ~/.zshrc
EOT

sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchTitus/pkg-files/${DESKTOP_ENV}.txt | while read line
do
  if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]
  then
    # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
    continue
  fi
  echo "INSTALLING: ${line}"
  sudo pacman -S --noconfirm --needed ${line}
done

if [[ ! $AUR_HELPER == none ]]; then
  cd ~
  git clone "https://aur.archlinux.org/$AUR_HELPER.git"
  cd ~/$AUR_HELPER
  makepkg -si --noconfirm
  # Sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
  # Stop the script and move on, not installing any more packages below that line
  sed -n '/'$INSTALL_TYPE'/q;p' ~/ArchTitus/pkg-files/aur-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    $AUR_HELPER -S --noconfirm --needed ${line}
  done
fi

export PATH=$PATH:~/.local/bin

# Theming DE if user chose FULL installation
if [[ $INSTALL_TYPE == "FULL" ]]; then
  if [[ $DESKTOP_ENV == "kde" ]]; then
    cp -r ~/ArchTitus/configs/.config/* ~/.config/
    pip install konsave
    konsave -i ~/ArchTitus/configs/kde.knsv
    sleep 1
    konsave -a kde
  elif [[ $DESKTOP_ENV == "openbox" ]]; then
    cd ~
    git clone https://github.com/stojshic/dotfiles-openbox
    ./dotfiles-openbox/install-titus.sh
  fi
fi

echo -ne "
-------------------------------------------------------------------------
                    System Ready For The Third Setup Process
-------------------------------------------------------------------------
"
exit
