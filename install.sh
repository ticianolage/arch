#!/bin/bash

# Funções auxiliares

. ./helper.sh --source-only
rm ~/DOTFILES-REMIDERS.txt
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GIT_DIR=`mktemp -d -p "$DIR"`

echo "Iniciando reconfiguração do sistema"

ask "Deseja prosseguir?" &&

echo "Instalando AUR helper"
gpg --recv-keys 4C3CE98F9579981C21CA1EC3465022E743D71E39
cd $GIT_DIR
mkdir aurman
cd aurman
git clone https://aur.archlinux.org/aurman.git .
makepkg -Si --noconfirm
cd $DIR

if ask "Deseja configurar os arquivos de boot?" S; then
    echo "Instalando intel-ucode"
    sudo pacman -S intel-ucode --noconfirm
    Remind "Adicionar \"initrd /intel-ucode.img\" após vmlinuz no arquivo .conf de /boot/loader/entries"
    echo "Copiando mkinitcpio.conf"
    sudo ln -sf root/etc/mkinitcpio.conf /etc/mkinitcpio.conf
fi

if ask "Instalar para Razer Blade?" S; then
    echo "Instalando AcpiFix"
    installRazerAcpiFix
    Remind "Adicionar \"initrd /razer_acpi_fix.img\" após o ucode no arquivo .conf de /boot/loader/entries"
    echo "Instalando Razer Genie"
    aurman -S openrazer-meta razergenie --noconfirm
    echo "Instalando TLP"
    sudo pacman -S tlp
    sudo systemctl enable tlp tlp-sleep
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
    sudo ln -sf dotfiles/root/etc/default/tlp /etc/default/tlp
fi

if ask "Deseja configurar bumblebee e nvidia-xrun?" S; then
    sudo pacman -S bumblebee bbswitch-dkms mesa nvidia-beta lib32-virtualgl lib32-nvidia-utils primus lib32-primus --noconfirm
    sudo gpasswd -a $USER bumblebee
    sudo systemctl enable bumblebeed
    echo "Copiando arquivo de configuração"
    sudo ln -s root/etc/bumblebee/bumblebee.conf /etc/bumblebee/bumblebee.conf
    
    cd $GIT_DIR
    mkdir nvidia-xrun
    cd nvidia-xrun
    git clone https://aur.archlinux.org/nvidia-xrun-git.git .
    makepkg -Si --noconfirm
    cd $DIR
    echo "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json vblank_mode=0 startkde" ~/.nvidia-xinitrc
fi

if ask "Deseja configurar o kdeplasma?" S; then
    sudo pacman -S plasma-meta sddm --noconfirm
    rm ~/.config/kdeglobals
    ln -sf home/config/kdeglobals ~/.config/kdeglobals
    rm ~/.config/plasmarc
    ln -sf home/config/plasmarc ~/.config/plasmarc
    aurman -S plymouth
    Remind "Reconfigurar o mkinitcpio com # mkinitcpio -p linux ou linux-ck"
    Remind "Habilitar sddm ou sddm-plymouth, a depender da preferência"
fi

if ask "Deseja configurar plataformas de jogos (incluindo wine)?" S; then
    echo "Instalando steam"
    sudo pacman -S steam --noconfirm
    echo "Instalando wine"
    aurman -S wine-staging-pba --noconfirm
    sudo pacman -S winetricks --noconfirm
    aurman -S dxvk-bin --noconfirm
    WINEPREFIX=~/.wine wineboot --init
    WINEPREFIX=~/.wine setup_dxvk64
    WINEPREFIX=~/.wine setup_dxvk32
fi