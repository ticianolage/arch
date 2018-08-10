#!/bin/bash

# Funções auxiliares

. ./helper.sh --source-only
rm -f ~/DOTFILES-REMIDERS.txt
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GIT_DIR=`mktemp -d -p "$DIR"`
echo "Iniciando reconfiguração do sistema"

ask "Deseja prosseguir?" &&
if pacman -Qi aurman | grep -q "erro"; then
    echo "Instalando AUR helper"
    gpg --recv-keys 4C3CE98F9579981C21CA1EC3465022E743D71E39
    cd $GIT_DIR
    echo "1"
    mkdir aurman
    echo "2"
    cd aurman
    git clone https://aur.archlinux.org/aurman.git .
    makepkg -si --noconfirm
    cd $DIR
fi

if verifyPacman ufw "Firewall"; then
    sudo systemctl enable ufw
    sudo systemctl start ufw
    sudo ufw default deny
    sudo ufw allow from 192.168.0.0/24
    sudo ufw allow Deluge
    sudo ufw limit SSH
    sudo ufw enable
    sudo ufw status
fi

verifyPacman ttf-ms-fonts "fontes"

echo "Configurando mirrors pacman"
sudo cp -f root/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
echo "Configurando pacman"
sudo cp -f root/etc/pacman.conf /etc/pacman.conf
sudo pacman -S pacman-contrib --noconfirm
sudo systemctl enable --now paccache.timer
echo "Configurando alsi"
aurman -S alsi --noconfirm
echo "Configurando bluetooth"
sudo pacman -S bluez bluez-utils pulseaudio-alsa pulseaudio-bluetooth bluez-libs --noconfirm
sudo systemctl enable --now bluetooth

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
    sudo mv -f openrazer-daemon.service /usr/lib/systemd/system/
    systemctl --user enable openrazer-daemon
    sudo gpasswd -a $USER plugdev
    echo "Instalando TLP"
    sudo pacman -S tlp
    
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket
    sudo ln -sf $(pwd)/root/etc/default/tlp /etc/default/tlp
    sudo systemctl enable --now tlp tlp-sleep
    sudo ln -sf $(pwd)/root/etc/systemd/logind.conf /etc/systemd/logind.conf
fi

if ask "Deseja configurar bumblebee e nvidia-xrun?" S; then
    sudo pacman -S bumblebee bbswitch-dkms mesa nvidia-beta lib32-virtualgl lib32-nvidia-utils primus lib32-primus --noconfirm
    sudo gpasswd -a $USER bumblebee
    sudo systemctl enable bumblebeed
    echo "Copiando arquivo de configuração"
    sudo ln -sf $(pwd)/root/etc/bumblebee/bumblebee.conf /etc/bumblebee/bumblebee.conf
    
    cd $GIT_DIR
    mkdir nvidia-xrun
    cd nvidia-xrun
    git clone https://aur.archlinux.org/nvidia-xrun-git.git .
    makepkg -si --noconfirm
    cd $DIR
    echo "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json vblank_mode=0 startkde" ~/.nvidia-xinitrc
fi

if ask "Deseja configurar o kdeplasma?" S; then
    sudo pacman -S plasma-meta sddm packagekit-qt5 --noconfirm
    rm ~/.config/kdeglobals
    ln -sf $(pwd)/home/config/kdeglobals ~/.config/kdeglobals
    rm ~/.config/plasmarc
    ln -sf $(pwd)/home/config/plasmarc ~/.config/plasmarc
    aurman -S plymouth --noconfirm
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

if ask "Configurar programas?" S; then
    echo "Instalando visual-studio-code-bin"
    aurman -S visual-studio-code-bin --noconfirm
    echo "Instalando chromium"
    sudo pacman -S chromium pepper-flash --noconfirm
    aurman -S chromium-widevine --noconfirm
    echo "Instalando mailspring"
    aurman -S mailspring --noconfirm
    echo "Instalando libreoffice"
    aurman -S libreoffice-fresh hunspell-pt-br libreoffice-extension-languagetool jre8-openjdk libreoffice-fresh-pt-br --noconfirm
    echo "Instalando spotify"
    aurman -S spotify --noconfirm
fi

rm -rf tmp.*