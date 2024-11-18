#!/bin/bash

# Определения цветов и форматирования
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Иконки для пунктов меню
ICON_TELEGRAM="🚀"
ICON_INSTALL="🛠️"
ICON_LOGS="📄"
ICON_STOP="⏹️"
ICON_START="▶️"
ICON_WALLET="💰"
ICON_EXIT="❌"
ICON_CHANGE_RPC="🔄"
ICON_DELETE="🗑️"
ICON_KEFIR="🍼"

# Функции для рисования границ
draw_top_border() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
}

draw_middle_border() {
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
}

draw_bottom_border() {
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}
print_telegram_icon() {
    echo -e "          ${MAGENTA}${ICON_TELEGRAM} Подписывайтесь на наш Telegram!${RESET}"
}

# Логотип и информация
display_ascii() {
    echo -e "${CYAN}   ____   _  __   ___    ____ _   __   ____ ______   ____   ___    ____${RESET}"
    echo -e "${CYAN}  /  _/  / |/ /  / _ \  /  _/| | / /  /  _//_  __/  /  _/  / _ |  / __/${RESET}"
    echo -e "${CYAN} _/ /   /    /  / // / _/ /  | |/ /  _/ /   / /    _/ /   / __ | _\ \  ${RESET}"
    echo -e "${CYAN}/___/  /_/|_/  /____/ /___/  |___/  /___/  /_/    /___/  /_/ |_|/___/  ${RESET}"
    echo -e ""
    echo -e "${YELLOW}Подписывайтесь на Telegram: https://t.me/CryptalikBTC${RESET}"
    echo -e "${YELLOW}Подписывайтесь на YouTube: https://www.youtube.com/@Cryptalik${RESET}"
    echo -e "${YELLOW}Здесь про аирдропы и ноды: https://t.me/indivitias${RESET}"
    echo -e "${YELLOW}Купи мне бутылочку... ${ICON_KEFIR}кефира 😏${RESET}"
    echo -e "${GREEN}https://bit.ly/4eBbfIr${RESET}"
    echo -e ""
    echo -e "${CYAN}Полезные команды:${RESET}"
    echo -e "  - ${YELLOW}Просмотр файлов директории:${RESET} ls"
    echo -e "  - ${YELLOW}Вход в директорию:${RESET} cd docker-browser"
    echo -e "  - ${YELLOW}Выход из директории:${RESET} cd .."
    echo -e ""
}

# Функция для получения IP-адреса
get_ip_address() {
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi
    echo "$ip_address"
}

show_menu() {
    clear
    draw_top_border
    display_ascii
    draw_middle_border
    print_telegram_icon
    echo -e "    ${BLUE}Криптан, подпишись!: ${YELLOW}https://t.me/indivitias${RESET}"
    draw_middle_border

    # Отображаем текущую рабочую директорию и IP-адрес
    current_dir=$(pwd)
    ip_address=$(get_ip_address)
    echo -e "    ${GREEN}Текущая директория:${RESET} ${current_dir}"
    echo -e "    ${GREEN}IP-адрес:${RESET} ${ip_address}"
    draw_middle_border

    echo -e "    ${YELLOW}Пожалуйста, выберите опцию:${RESET}"
    echo
    echo -e "    ${CYAN}1.${RESET} ${ICON_INSTALL} Установить узел"
    echo -e "    ${CYAN}2.${RESET} ${ICON_LOGS} Просмотреть логи Typesense"
    echo -e "    ${CYAN}3.${RESET} ${ICON_LOGS} Просмотреть логи узлов Ocean"
    echo -e "    ${CYAN}4.${RESET} ${ICON_STOP} Остановить узел"
    echo -e "    ${CYAN}5.${RESET} ${ICON_START} Запустить узел"
    echo -e "    ${CYAN}6.${RESET} ${ICON_WALLET} Просмотреть созданные кошельки"
    echo -e "    ${CYAN}7.${RESET} ${ICON_CHANGE_RPC} Изменить RPC"  # Новый пункт меню
    echo -e "    ${CYAN}0.${RESET} ${ICON_EXIT} Выйти"
    echo
    draw_bottom_border
    echo -ne "    ${YELLOW}Введите ваш выбор [0-7]:${RESET} "  # Обновленный диапазон до [0-7]
    read choice
}

install_node() {
    echo -e "${GREEN}🛠️  Установка узла...${RESET}"
    # Обновление системы
    sudo apt update && sudo apt upgrade -y

    # Установка Docker, если не установлен
    if ! command -v docker &> /dev/null; then
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker
    fi

    # Установка Docker Compose, если не установлен
    if ! command -v docker-compose &> /dev/null; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    # Установка Python3 и pip3, если не установлены
    if ! command -v python3 &> /dev/null; then
        sudo apt install python3 -y
    fi
    if ! command -v pip3 &> /dev/null; then
        sudo apt install python3-pip -y
    fi

    # Установка crontab, если не установлен
    if ! command -v crontab &> /dev/null; then
        sudo apt install cron -y
        sudo systemctl enable cron
        sudo systemctl start cron
    fi

    # Установка необходимых библиотек Python
    pip3 install eth_account requests

    # Запрос количества узлов
    echo -ne "${YELLOW}Введите количество узлов:${RESET} "
    read num_nodes

    # Получение IP-адреса
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi

    # Запуск script.py с IP-адресом и количеством узлов
    python3 script.py "$ip_address" "$num_nodes"
    docker network create ocean_network
    # Запуск сервисов Docker Compose для каждого узла
    for ((i=1; i<=num_nodes+1; i++)); do
        docker-compose -f docker-compose$i.yaml up -d
    done
    current_dir=$(pwd)
    # Запланировать выполнение req.py каждый час с помощью crontab
    (crontab -l 2>/dev/null; echo "0 * * * * python3 $(pwd)/req.py $ip_address $current_dir") | crontab -

    echo -e "${GREEN}✅ Узел успешно установлен.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

view_typesense_logs() {
    echo -e "${GREEN}📄 Просмотр логов Typesense...${RESET}"
    docker logs typesense
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

view_ocean_node_logs() {
    echo -ne "${YELLOW}Введите количество узлов:${RESET} "
    read num_nodes
    echo -ne "${YELLOW}Выберите узел для просмотра логов (1-${num_nodes}):${RESET} "
    read node_number
    echo -e "${GREEN}📄 Просмотр логов ocean-node-${node_number}...${RESET}"
    docker logs ocean-node-$node_number
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

stop_node() {
    echo -ne "${YELLOW}Введите количество узлов:${RESET} "
    read num_nodes
    echo -e "${GREEN}⏹️  Остановка узлов...${RESET}"
    for ((i=1; i<=num_nodes+1; i++)); do
        docker-compose -f docker-compose$i.yaml down
    done

    # Удаление записи в crontab для req.py
    crontab -l | grep -v "req.py" | crontab -

    echo -e "${GREEN}✅ Узлы остановлены и запись в crontab удалена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

start_node() {
    echo -ne "${YELLOW}Введите количество узлов:${RESET} "
    read num_nodes

    # Получение IP-адреса
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi

    echo -e "${GREEN}▶️  Запуск узлов...${RESET}"
    for ((i=1; i<=num_nodes+1; i++)); do
        docker-compose -f docker-compose$i.yaml up -d
    done
    
    ip_address=$(hostname -I | awk '{print $1}')
    if [[ -z "$ip_address" ]]; then
        echo -ne "${YELLOW}Не удалось автоматически определить IP-адрес.${RESET}"
        echo -ne "${YELLOW} Пожалуйста, введите IP-адрес:${RESET} "
        read ip_address
    fi
    
    current_dir=$(pwd)
    # Запланировать выполнение req.py каждый час с помощью crontab
    (crontab -l 2>/dev/null; echo "0 * * * * python3 $(pwd)/req.py $ip_address $current_dir") | crontab -

    echo -e "${GREEN}✅ Узлы запущены и запись в crontab добавлена.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

view_wallets() {
    echo -e "${GREEN}💰 Просмотр созданных кошельков...${RESET}"
    cat wallets.json
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Новая функция для изменения RPC
change_rpc() {
    echo -e "${GREEN}🔄 Изменение RPC...${RESET}"
    
    # Установка библиотеки yaml, если не установлена
    echo -e "${YELLOW}Установка библиотеки YAML...${RESET}"
    pip3 install yaml
    
    # Определение URL скрипта RPC.py
    RPC_URL="https://raw.githubusercontent.com/dknodes/ocean/master/RPC.py"
    
    # Скачивание RPC.py
    echo -e "${YELLOW}Скачивание скрипта RPC.py...${RESET}"
    wget -O RPC.py "$RPC_URL"
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ Не удалось скачать RPC.py.${RESET}"
        echo
        read -p "Нажмите Enter, чтобы вернуться в главное меню..."
        return
    fi
    
    # Запуск RPC.py
    echo -e "${YELLOW}Запуск RPC.py...${RESET}"
    python3 RPC.py
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✅ RPC успешно изменен.${RESET}"
    else
        echo -e "${RED}❌ Произошла ошибка при изменении RPC.${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

# Главный цикл
while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            view_typesense_logs
            ;;
        3)
            view_ocean_node_logs
            ;;
        4)
            stop_node
            ;;
        5)
            start_node
            ;;
        6)
            view_wallets
            ;;
        7)  # Новый пункт для изменения RPC
            change_rpc
            ;;
        0)
            echo -e "${GREEN}❌ Выход...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Неверный выбор. Попробуйте снова.${RESET}"
            echo
            read -p "Нажмите Enter для продолжения..."
            ;;
    esac
done
