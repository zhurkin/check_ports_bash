#!/usr/bin/env bash

# Time to wait for connection for each server / Время ожидания соединения для каждого сервера
VAR_TIMEOUT_TCP=3

# List of target servers specified in variables.txt / Список целевых серверов, указанных в файле variables.txt
VAR_CHECK_TARGET=($(sed 's/\s.*//' check_target_vars.txt))

# Function to check target server availability / Функция проверки доступности целевых серверов
check_target() {
    while read -r VAR_LOOP_CHECK_TARGET; do
        # Replace first delimiter with / / Замена первого разделителя на /
        VAR_LOOP_CHECK_TARGET=$(echo $VAR_LOOP_CHECK_TARGET | sed 's/\([: ]\)/\//')

        # Check if the target is reachable / Проверка доступности целевого сервера
        timeout $VAR_TIMEOUT_TCP bash -c "< /dev/null > /dev/tcp/$VAR_LOOP_CHECK_TARGET"

        if [ $? -eq 0 ]; then
            echo $VAR_LOOP_CHECK_TARGET ok
        else
            echo $VAR_LOOP_CHECK_TARGET error
        fi
    done < check_target_vars.txt
}

# Call the function to check target server availability / Вызов функции проверки доступности целевых серверов
check_target
