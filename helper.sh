#!/bin/bash

# Algumas Funções foram copiadas de https://github.com/Mastermindzh/dotfiles - será referenciado como (1)

# Função para fazer uma pergunta e obter resposta do usuário
ask() {
    # from https://djm.me/ask
    local prompt default reply

    while true; do

        if [ "${2:-}" = "S" ]; then
            prompt="S/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="s/N"
            default=N
        else
            prompt="s/n"
            default=
        fi
        echo -n "$1 [$prompt] "
        read reply </dev/tty

        if [ -z "$reply" ]; then
            reply=$default
        fi

        case "$reply" in
			[Ss]*) return 0  ;;
            [Nn]*) return  1 ;;
        esac

    done
}


# Função para criar os links simbólicos de diretórios
function linkDir {
	rm -rf $2;
	mkdir -p "${2%/*}"
	ln -sf $1 $2
}


# Função para copiar os arquivos para o diretório
function copyToDir {
	echo $2 | sed 's%/[^/]*$%/%' | xargs mkdir -p
	cp $1 $2
}


function installRazerAcpiFix {
    echo "Copiando arquivo razer_acpi_fix.img para /boot/"
    sudo rm -rf /boot/razer_acpi_fix.img
    sudo cp others/razer/razer_acpi_fix.img /boot/razer_acpi_fix.img
}

function Remind {
    echo "Reminder: $1" | tee -a ~/DOTFILES-REMIDERS.txt
}