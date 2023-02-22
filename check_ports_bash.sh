#!/usr/bin/env bash

# # Time to wait for connection for each server in seconds / Время ожидания соединения для каждого сервера в секундах
VAR_TIMEOUT_TCP=3

## List of target servers specified in check_target_vars.txt / Список целевых серверов, указанных в файле check_target_vars.txt
readarray -t VAR_CHECK_TARGET < check_target_vars.txt

# Define function to check if targets are reachable / Функция для проверки доступности серверов
check_target() {
    for VAR_LOOP_CHECK_TARGET in "${VAR_CHECK_TARGET[@]}"
    do
        # Check if string contains : or / / # Проверка, содержит ли строка символы : или /
        if [[ "$VAR_LOOP_CHECK_TARGET" == *[:/]* ]]; then
            # Replace : with / to allow for IP address and domain name formats / Замена : на / для обеспечения поддержки форматов IP-адресов и доменных имен
            VAR_LOOP_CHECK_TARGET=${VAR_LOOP_CHECK_TARGET/:/\/}
        else
            # Split the target string by space and append the port number / Разделение строки цели по пробелу и добавление номера порта
            read -r VAR_LOOP_CHECK_TARGET VAR_LOOP_CHECK_PORT <<< "$VAR_LOOP_CHECK_TARGET"
            VAR_LOOP_CHECK_TARGET="$VAR_LOOP_CHECK_TARGET/$VAR_LOOP_CHECK_PORT"
        fi

        # Check if the server is reachable / Проверка доступности серверов
        timeout $VAR_TIMEOUT_TCP bash -c "< /dev/null > /dev/tcp/$VAR_LOOP_CHECK_TARGET"

        if [ $? -eq 0 ]; then
            echo $VAR_LOOP_CHECK_TARGET ok
        else
            echo $VAR_LOOP_CHECK_TARGET error
        fi
    done
}

# Check for command line arguments
if [[ $# -eq 0 ]]; then
  check_target
  exit 0
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: check_ports_bash.sh [-t TARGET] [-h]"
  echo "  -t, --target       target server to check, in the format of IP or domain name followed by port number, separated by /, :, or space"
  echo "  -h, --help         display this help and exit"
  exit 0
elif [[ "$1" == "-t" || "$1" == "--target" ]]; then
  shift
  if [[ $# -eq 1 ]]; then
    VAR_CHECK_TARGET=("$1")
    check_target
    exit 0
  elif [[ $# -eq 2 ]]; then
    IFS=$' \t\n'
    VAR_CHECK_TARGET=("$1 $2")
    check_target
    exit 0
  else
    echo "Error: invalid number of arguments for -t option"
    exit 1
  fi
else
  echo "Error: invalid option"
  exit 1
fi
