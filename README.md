# Установщик Home Assistant Supervised на устройства семейства OrangePI
> **Постоянно находится в состоянии тестирования, потому-что мир посточнно меняется и собарть конфигурацию под все версии ПО сложно**

Позволяет более простым путем установить Home Assistant Supervised на OrangePi (спасибо nikita51bot, который написал исходный скрипт)

Протестированно:
  - Orange pi 3 lts 
## Установка
- Установить на OrangePi Debian 11 (Тестировалось на Orange Pi 3.0.8 Bullseye with Linux 5.16.17-sun50iw6), подключиться по SSH
 (Выполнить команду "sudo nand-sata-install", Выбираем “2”, форматируем в “ext4”, жмем “Ок”, ждем переноса с карты на встроенную память. После завершения выключаемся, вытаскиваем MicroSD и включаемся. Пошла грузиться Debian — значит все правильно. Дальнейшие действия производим здесь. MicroSD больше не нужна. (Источник: https://psenyukov.ru/%D1%83%D1%81%D1%82%D0%B0%D0%BD%D0%BE%D0%B2%D0%BA%D0%B0-home-assistant-%D0%BD%D0%B0-orange-pi-4-lts/))
- Скачать файл: `wget https://raw.githubusercontent.com/SerYojik667/HomeAssistantInstallScript/main/install.sh`
- Запустить файл и следовать инструкции: `sudo bash install.sh`
- Во время работы скипта он перезагрузит систему и потребуется повторный запуск скрипта для проджолжения установки. 
Повторный запуск рекомендуется производить с того IP адреса на котором будет работать Home Assistant, тогда при установке он автоматически запустится на этом IP (Например если Homa Assistant должен работаь через WIFI то по SSH следует подключиться именно к этому адресу)
- В конце, при выборе machine type, выберите **odroid-c2**
