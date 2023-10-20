#!/bin/bash
# execute command received via command line
sshpass -priscv ssh -p 22222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost "$@"