#!/bin/sh

function info { echo -e "\e[32m[info] $*\e[39m"; }
function warn  { echo -e "\e[33m[warn] $*\e[39m"; }
function error { echo -e "\e[31m[error] $*\e[39m"; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
    warn "Введите: sudo bash $(dirname "$0")/$(basename "$0")">&2
    exit 1
fi

beforestart () {

    info "Настоятельно рекомендуем перед началом обновить все библиотеки (apt update && apt upgrade)"
    while true; do
        read -p "Обновить все библиотеки? Yes - обновить, No - продолжить без обновления (yes/no): " yn
        case $yn in
            [Yy]* ) sudo apt update && sudo apt upgrade -y; break;;
            [Nn]* ) break;;
            * );;
        esac
    done

    info "Проверка конфигурации orangepiEnv.txt"
    configurated=true
    text_for_configuration=""
    if ! grep -q "extraargs=apparmor=1" /boot/orangepiEnv.txt
    then
        configurated=false
        text_for_configuration="$text_for_configuration""extraargs=apparmor=1\n"
    fi
    if ! grep -q "security=apparmor" /boot/orangepiEnv.txt
    then
        configurated=false
        text_for_configuration="$text_for_configuration""security=apparmor\n"
    fi
    if ! grep -q "systemd.unified_cgroup_hierarchy=false" /boot/orangepiEnv.txt
    then
        configurated=false
        text_for_configuration="$text_for_configuration""systemd.unified_cgroup_hierarchy=false\n"
    fi
    if ! grep -q "systemd.legacy_systemd_cgroup_controller=false" /boot/orangepiEnv.txt
    then
        configurated=false
        text_for_configuration="$text_for_configuration""systemd.legacy_systemd_cgroup_controller=false\n"
    fi

    if $configurated
    then
        afterstart
    else
        info "Настройка конфигурации"
        cp /boot/orangepiEnv.txt /boot/orangepiEnv.txt.bak
        echo -e $text_for_configuration >> /boot/orangepiEnv.txt
        warn "Компьютер перезагрузится через 10 секунд, запустите скрипт снова после перезагрузки (для отмены Ctrl+C)"
        sleep 10
        touch ~/.isrestart
        reboot
    fi



    
}

afterstart () {
    info "Установка Docker"
    sudo curl -fsSL get.docker.com | sh
    info "Установка прав докера для текущего пользователя"
    sudo usermod -aG docker $USER
    info "Установка необходимых библиотек"
    sudo apt-get install -y jq wget curl udisks2 libglib2.0-bin network-manager dbus apparmor systemd-journal-remote
    info "Установка московского часового пояса"
    sudo timedatectl set-timezone Europe/Moscow
    info "Установка OS agent"
    curl -s https://api.github.com/repos/home-assistant/os-agent/releases/latest | grep "browser_download_url.*aarch64\.deb" | cut -d : -f 2,3 | tr -d \" | wget -O os-agent-aarch64.deb -i -
    sudo dpkg -i os-agent-aarch64.deb
    info "Установка Home Assistant Supervised"
    wget https://github.com/home-assistant/supervised-installer/releases/latest/download/homeassistant-supervised.deb
    warn "Сейчас появится меню с выбором, выберите odroid-c2"
    sleep 5
    sudo dpkg -i --ignore-depends=systemd-resolved homeassistant-supervised.deb
    sudo rm -rf homeassistant-supervised.deb os-agent-aarch64.deb

    echo -e "\n\n"
    info "Установка Home Assistant прошла успешно"
    # wifisetup
    # Присутствует проблема с присоединением к Wifi с защитой WPA3
}

wifisetup () {
    while true; do
        read -p "Хотите подключить компьютер к Wifi? (yes/no): " yn
        case $yn in
            [Yy]* ) break;;
            * ) exit 0;;
        esac
    done
    echo "Список Wifi сетей:"
    nmcli d wifi list
    read -p "Введите название сети(SSID/BSSID): " wifi_ssid
    read -p "Введите пароль от сети: " wifi_password
    echo "$wifi_ssid $wifi_password"
    nmcli dev wifi connect $wifi_ssid password $wifi_password; echo status=$?
}

if [ -f ~/.isrestart ]; then
    rm ~/.isrestart
    afterstart
else
    beforestart
fi