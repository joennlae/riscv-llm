#!/bin/bash
# copy files via scp
sshpass -priscv scp -P 22222 -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ""$@"" root@localhost:/root