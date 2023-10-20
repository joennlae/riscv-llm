# this script is only needed inside iis env

# install sshpass
mkdir -p install/sshpass
cd install/sshpass

dnf download sshpass --resolve
# translate to bash
for rpm in *.rpm
do
  rpm2cpio $rpm | cpio --extract --make-directories --preserve-modification-time -v
done

