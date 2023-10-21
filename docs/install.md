## Install GCC-13 fast on Ubuntu 22.04

We do an ugly trick by installing GCC-13 from Ubuntu 23.04 on Ubuntu 22.04. This is because Ubuntu 22.04 does not have GCC-13 in its repositories.
https://packages.ubuntu.com/lunar/g++-13

We do that by adding the correct repository to `/etc/apt/sources.list`.