  #!/bin/bash

# Security Reinforce for CentOS78
# Date: 2021.06.02
# Version: 3.0
# Author: Apt

#xiping.zhao

####################
# env set
#grub_superuser="root"
grub_password="redhat"


####################
# encrypt grub
## backup grub.cfg
cp /boot/grub2/grub.cfg /boot/grub2/grub.cfg-`date +%Y%m%d%H%M`


## encrypt grub
GRUB2_PASSWORD=`echo -e "${grub_password}\n${grub_password}\n" | grub2-mkpasswd-pbkdf2 | grep PBKDF2 | awk '{print $7}'`
### superuser is root
echo "GRUB2_PASSWORD=${GRUB2_PASSWORD}" > /boot/grub2/user.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1
## modify permission
chown root:root /boot/grub2/grub.cfg
chmod go-rwx /boot/grub2/grub.cfg
chown root:root /boot/grub2/user.cfg
chmod go-rwx /boot/grub2/user.cfg
chown root:root /boot/grub2/grubenv
chmod go-rwx /boot/grub2/grubenv


####################
# set kernel args
grep "hard core 0" /etc/security/limits.conf || echo "* hard core 0" >> /etc/security/limits.conf
grep "fs.suid_dumpable" /etc/sysctl.conf || echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
sysctl -w fs.suid_dumpable=0 >/dev/null 2>&1
grep "kernel.randomize_va_space" /etc/sysctl.conf || echo "kernel.randomize_va_space = 2" >> /etc/sysctl.conf
sysctl -w kernel.randomize_va_space=2 >/dev/null 2>&1


####################
# modify sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config-`date +%Y%m%d%H%M`
grep ^ClientAliveInterval /etc/ssh/sshd_config || sed -i '/ClientAliveInterval/aClientAliveInterval 300' /etc/ssh/sshd_config
grep ^ClientAliveCountMax /etc/ssh/sshd_config || sed -i '/ClientAliveCountMax/aClientAliveCountMax 0' /etc/ssh/sshd_config
grep ^MaxAuthTries /etc/ssh/sshd_config || sed -i '/MaxAuthTries/aMaxAuthTries 4' /etc/ssh/sshd_config
grep ^PermitEmptyPasswords /etc/ssh/sshd_config || sed -i '/PermitEmptyPasswords/aPermitEmptyPasswords no' /etc/ssh/sshd_config


####################
# modify umask
#echo "umask 027" >> /etc/bashrc
#echo "umask 027" >> /etc/profile 
grep "umask 002" /etc/bashrc >/dev/null && sed -i 's/umask 002/umask 027/g' /etc/bashrc
grep "umask 002" /etc/profile >/dev/null && sed -i 's/umask 002/umask 027/g' /etc/profile
grep "umask 022" /etc/bashrc >/dev/null && sed -i 's/umask 022/umask 027/g' /etc/bashrc
grep "umask 022" /etc/profile >/dev/null && sed -i 's/umask 022/umask 027/g' /etc/profile


####################
# modify TMOUT
grep ^TMOUT /etc/profile || echo "TMOUT=600" >> /etc/profile
grep ^TMOUT /etc/bashrc || echo "TMOUT=600" >> /etc/bashrc


####################
# Modify login lock
sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
sed -i '/auth[[:space:]]*required[[:space:]]*pam_env.so/a\auth        required      pam_faillock.so preauth audit silent deny=5 unlock_time=900' /etc/pam.d/system-auth
sed -i '/auth[[:space:]]*sufficient[[:space:]]*pam_unix.so/a\auth        sufficient pam_faillock.so authsucc audit deny=5 unlock_time=900' /etc/pam.d/system-auth
sed -i '/auth[[:space:]]*sufficient[[:space:]]*pam_unix.so/a\auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900' /etc/pam.d/system-auth
sed -i '/auth[[:space:]]*sufficient[[:space:]]*pam_unix.so/a\auth        [success=1 default=bad] pam_unix.so' /etc/pam.d/system-auth

sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
sed -i '/auth[[:space:]]*required[[:space:]]*pam_env.so/a\auth        required      pam_faillock.so preauth audit silent deny=5 unlock_time=900' /etc/pam.d/password-auth
sed -i '/auth[[:space:]]*sufficient[[:space:]]*pam_unix.so/a\auth        sufficient pam_faillock.so authsucc audit deny=5 unlock_time=900' /etc/pam.d/password-auth
sed -i '/auth[[:space:]]*sufficient[[:space:]]*pam_unix.so/a\auth        [default=die] pam_faillock.so authfail audit deny=5 unlock_time=900' /etc/pam.d/password-auth
sed -i '/auth[[:space:]]*sufficient[[:space:]]*pam_unix.so/a\auth        [success=1 default=bad] pam_unix.so' /etc/pam.d/password-auth


####################
# Enable XD/NX
grep "noexec=on" /etc/default/grub || sed -i 's/crashkernel=auto /crashkernel=auto noexec=on /' /etc/sysconfig/grub
grub2-mkconfig -o /boot/grub2/grub.cfg >/dev/null 2>&1



####################
# End
echo "$0 execute is completed"
