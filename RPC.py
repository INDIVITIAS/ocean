import os
import glob
import yaml
import json
import copy

# Дефолтные RPC-конфигурации
DEFAULT_RPCS = {
    "1": {
        "rpc": "https://ethereum-rpc.publicnode.com",
        "fallbackRPCs": [
            "https://rpc.ankr.com/eth",
            "https://1rpc.io/eth",
            "https://eth.api.onfinality.io/public"
        ],
        "chainId": 1,
        "network": "mainnet",
        "chunkSize": 100
    },
    "10": {
        "rpc": "https://mainnet.optimism.io",
        "fallbackRPCs": [
            "https://optimism-mainnet.public.blastapi.io",
            "https://rpc.ankr.com/optimism",
            "https://optimism-rpc.publicnode.com"
        ],
        "chainId": 10,
        "network": "optimism",
        "chunkSize": 100
    }
    # Дополните по необходимости...
}

# Пользовательский шаблон RPC
CUSTOM_RPCS_TEMPLATE = {
    "1": {
        "rpc": "https://eth-mainnet.g.alchemy.com/v2/{API_KEY}",
        "fallbackRPCs": [
            "https://rpc.ankr.com/eth",
            "https://1rpc.io/eth"
        ],
        "chainId": 1,
        "network": "mainnet",
        "chunkSize": 100
    },
    "10": {
        "rpc": "https://opt-mainnet.g.alchemy.com/v2/{API_KEY}",
        "fallbackRPCs": [
            "https://optimism-mainnet.public.blastapi.io",
            "https://rpc.ankr.com/optimism",
            "https://optimism-rpc.publicnode.com"
        ],
        "chainId": 10,
        "network": "optimism",
        "chunkSize": 100
    }
    # Дополните по необходимости...
}

# Поиск всех docker-compose файлов, кроме исключений
def get_docker_compose_files():
    all_files = glob.glob("docker-compose*.yaml")
    files = [f for f in all_files if os.path.basename(f) != "docker-compose1.yaml"]
    if not files:
        print("В текущей директории не найдено файлов docker-compose*.yaml, кроме docker-compose1.yaml.")
    else:
        print(f"Найдены файлы для обработки: {files}")
    return files

# Загрузка YAML-файла
def load_yaml(file_path):
    with open(file_path, 'r') as f:
        return yaml.safe_load(f)

# Сохранение YAML-файла
def save_yaml(content, file_path):
    with open(file_path, 'w') as f:
        yaml.dump(content, f, sort_keys=False, default_flow_style=False, allow_unicode=True)
    print(f"Файл обновлен: {file_path}")

# Генерация кастомных RPC
def construct_custom_rpcs(api_key):
    rpcs = copy.deepcopy(CUSTOM_RPCS_TEMPLATE)
    for chain_id, config in rpcs.items():
        if "{API_KEY}" in config["rpc"]:
            rpcs[chain_id]["rpc"] = config["rpc"].replace("{API_KEY}", api_key)
    return rpcs

# Основной процесс
def main():
    files = get_docker_compose_files()
    if not files:
        return

    print("\nВыберите, как вы хотите изменить RPC:")
    print("1. Заменить на стандартные RPC.")
    print("2. Заменить на пользовательские RPC с использованием вашего API-ключа.")
    choice = input("Введите 1 или 2: ").strip()

    if choice == '1':
        new_rpcs = DEFAULT_RPCS
    elif choice == '2':
        api_key = input("Введите ваш Alchemy API ключ: ").strip()
        if not api_key:
            print("API ключ не введен. Завершение работы.")
            return
        new_rpcs = construct_custom_rpcs(api_key)
    else:
        print("Неверный выбор. Завершение работы.")
        return

    rpcs_json = json.dumps(new_rpcs, separators=(',', ':'))

    for file in files:
        try:
            content = load_yaml(file)

            services = content.get('services', {})
            updated = False
            for service_name, service_config in services.items():
                env = service_config.get('environment', {})
                if 'RPCS' in env:
                    print(f"Обновление RPCS в сервисе '{service_name}' из файла '{file}'.")
                    env['RPCS'] = rpcs_json
                    updated = True
                else:
                    print(f"Переменная окружения RPCS не найдена в сервисе '{service_name}' из файла '{file}'. Пропуск.")

            if updated:
                save_yaml(content, file)
            else:
                print(f"Файл '{file}' не требует обновления.")

        except Exception as e:
            print(f"Ошибка при обработке файла '{file}': {e}")

# Запуск скрипта
if __name__ == "__main__":
    main()
