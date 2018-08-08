#!/bin/bash

# Funções auxiliares

. ./helper.sh --source-only
rm ~/DOTFILES-REMIDERS.txt
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GIT_DIR=`mktemp -d -p "$DIR"`
if ask "Deseja configurar os arquivos de boot?" S; then
    echo "Instalando intel-ucode"
    sudo pacman -S intel-ucode --noconfirm
    Remind "Reminder: adicionar \"initrd /intel-ucode.img\" após vmlinuz no arquivo .conf de /boot/loader/entries"
    if ask "Instalar acpi-fix para Razer Blade?" S; then
        installRazerAcpiFix
        Remind "Reminder: adicionar \"initrd /razer_acpi_fix.img\" após o ucode no arquivo .conf de /boot/loader/entries"
    fi
fi
if ask "Deseja configurar bumblebee e nvidia-xrun?" S; then
    sudo pacman -S bumblebee bbswitch-dkms mesa nvidia-beta lib32-virtualgl lib32-nvidia-utils primus lib32-primus --noconfirm
    sudo gpasswd -a $USER bumblebee
    sudo systemctl enable bumblebeed
    echo "Copiando arquivo de configuração"
    sudo ln -s root/etc/bumblebee/bumblebee.conf /etc/bumblebee/bumblebee.conf
    
    cd GIT_DIR
    mkdir nvidia-xrun
    cd nvidia-xrun
    git clone https://aur.archlinux.org/nvidia-xrun-git.git .
    makepkg -Si
    cd DIR
fi