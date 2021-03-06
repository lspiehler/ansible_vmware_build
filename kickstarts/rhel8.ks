%pre
#!/bin/bash
if [ -b /dev/vda ] ; then
	DISK="vda"
elif [ -b /dev/hda ] ; then
	DISK="hda"
else
	DISK="sda"
fi

echo "ignoredisk --only-use=${DISK}" > /tmp/onlyuse
echo "bootloader --location=mbr --boot-drive=${DISK} --append=\"console=tty0 console=ttyS0,119200n8\"" > /tmp/bootloader
echo "part pv.01 --size=1 --grow --ondisk=${DISK}" > /tmp/part

%end

install
lang en_US.UTF-8
#network  --bootproto=static --device=ens160 --onboot=on --hostname=<?php echo $_GET['hostname']; ?> --ip=<?php echo $_GET['ip']; ?> --netmask=<?php echo $_GET['mask']; ?> --gateway=<?php echo $_GET['gw']; ?> --nameserver=<?php echo $_GET['dns']; ?>

#network  --bootproto=dhcp --device=eth0 --onboot=on --hostname=<?php echo $_GET['hostname']; ?>

keyboard us
timezone America/Chicago --isUtc --ntpservers=lctiadgc01.lcmchealth.org,lctiadgc02.lcmchealth.org,lcucadgc01.lcmchealth.org,lcucadgc02.lcmchealth.org
#auth --useshadow --enablemd5
auth --passalgo=sha512 --useshadow
selinux --enforcing
firewall --enabled --ssh
services --enabled=NetworkManager,sshd
eula --agreed
%include /tmp/onlyuse
#ignoredisk --only-use=${DISK}
reboot
text

#bootloader --location=mbr --boot-drive=${DISK} --append="console=tty0 console=ttyS0,119200n8"
%include /tmp/bootloader
zerombr
clearpart --all --initlabel
part /boot --fstype xfs --size=1024
%include /tmp/part
#part pv.01 --size=1 --grow --ondisk=${DISK}
volgroup vg_root --pesize=4096 pv.01
logvol / --fstype="ext4" --size=10240 --vgname=vg_root --name=lv_root
logvol /var --fstype="ext4" --size=2048 --vgname=vg_root --name=lv_var
logvol swap --fstype="ext4" --size=1024 --vgname=vg_root --name=lv_swap

rootpw --iscrypted $6$vMXfFeQNEgDGy5.7$2hublUvL7txrLv.GSzNd5UYVnR/KtHL2PLosJ.TQxRC/rknq53StzaZXwK03OyjtaHzdRkvq6Fybfbl/pYYtT.
user --name=provision --iscrypted --password $6$KiaU8eBo/XcfCgEQ$HUvR2jvsSk1OwocsDyHLq2/9KcZduDGAYf2WkaGc2f7r7XtoSRIOJ4IU9C97rZkImuUJhfQspsCBo2VG/Cu1G.

#url --url="http://mirror.centos.org/centos/7/os/x86_64/"
#url --url="http://dev.spiehlerfamily.com/centos/7/os/x86_64/"

#url --url="http://lcuccssiemconn.lcmchealth.org/rhel/8/os/x86_64/"
#repo --name="AppStream" --baseurl="http://lcuccssiemconn.lcmchealth.org/rhel/8/os/x86_64/AppStream"

%packages
@core
%end
%post --log="/var/log/ks-post.log"

/usr/sbin/groupadd -g 999999 provision
/usr/sbin/useradd -u 999999 -g 999999 -m provision -s /bin/bash
/bin/mkdir /home/provision/.ssh/
/bin/chmod 700 /home/provision/.ssh/
/bin/cat << 'EOF' > /home/provision/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZ9HJh8ZapJZU2i5hSbJLJoNfiuBaL8FiJLQ6x8rPwwMYQ9jONRsgybXj4Q/mBuwUvZRPuZSrzfMJt+smGbgnASsaCWK/qpFDzgmIB5te4OJmUe12BYvGOVkr/Zx7uno1S1ketvia114eWfKneQluQITMf+jj8Co6WAflPqYkW/kLb47RSUqy0iKDYHSJyNUAXcLXCbYLVI8x2vf4n2egSb7T5vnJJxxG5wILNuQbXnzqVHhVclAYYkWDk9xud0sFFYsRwVWmNm5ruSu83YWTyI39VPvzokQgTgQO4mdWygD0XfXINACNFG5sIWlUvM70EiRaHSqkGiBMNZ/y0hkht provision@ansibletest01.lcmchealth.org
EOF
/bin/chmod 600 /home/provision/.ssh/authorized_keys
/bin/chown provision:provision -R /home/provision/.ssh/
/usr/bin/chcon -R -t ssh_home_t /home/provision/.ssh/

echo  -e 'provision\tALL=(ALL)\tNOPASSWD:\tALL' > /etc/sudoers.d/provision

%end
