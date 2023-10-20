#!/bin/bash

./start_riscv.sh

function wait_for() {
    timeout=$1
    shift 1
    until [ $timeout -le 0 ] || "$@"; do
        sleep 1
        timeout=$(( timeout - 1 ))
    done
    if [ $timeout -le 0 ]; then
        return 1
    fi
}

function is_still_booting() {
    cat system.log | grep --text "login:"
    boot_status=$?
    # check if system is booted
    if [ $boot_status -eq 0 ]; then
        echo "System is booted"
        return 0;
    else
        echo "System is booting"
        tail -n 10 system.log | sed 's/^/  ###  /'
        return 1;
    fi
}

wait_for 120 is_still_booting

./ssh.sh