%pre
#!/bin/bash
if [ -b /dev/vda ] ; then
	DISK="vda"
elif [ -b /dev/hda ] ; then
	DISK="hda"
else
	DISK="sda"
fi

echo "ignoredisk --only-use=${DISK},sdb,sdc,sdd,sde" > /tmp/onlyuse
echo "bootloader --location=mbr --boot-drive=${DISK} --append=\"console=tty0 console=ttyS0,119200n8\"" > /tmp/bootloader
echo "part pv.01 --size=1 --grow --ondisk=${DISK}" > /tmp/part

%end

install
lang en_US.UTF-8
#network  --bootproto=static --device=ens160 --onboot=on --hostname=<?php echo $_GET['hostname']; ?> --ip=<?php echo $_GET['ip']; ?> --netmask=<?php echo $_GET['mask']; ?> --gateway=<?php echo $_GET['gw']; ?> --nameserver=<?php echo $_GET['dns']; ?>

#network  --bootproto=dhcp --device=eth0 --onboot=on --hostname=<?php echo $_GET['hostname']; ?>

keyboard us
timezone America/Chicago --isUtc --ntpservers=0.rhel.pool.ntp.org,1.rhel.pool.ntp.org,2.rhel.pool.ntp.org,3.rhel.pool.ntp.org
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
part /boot --fstype ext4 --size=1024
%include /tmp/part
part pv.02 --size=1 --grow --ondisk=sdb
part pv.03 --size=1 --grow --ondisk=sdc
part pv.04 --size=1 --grow --ondisk=sdd
part pv.05 --size=1 --grow --ondisk=sde
#part pv.01 --size=1 --grow --ondisk=${DISK}
volgroup sys_vg --pesize=16384 pv.01
logvol / --fstype="ext4" --size=16384 --vgname=sys_vg --name=root_lv
logvol /usr --fstype="ext4" --size=10240 --vgname=sys_vg --name=usr_lv
logvol /var --fstype="ext4" --size=5120 --vgname=sys_vg --name=var_lv
logvol /opt --fstype="ext4" --size=2048 --vgname=sys_vg --name=opt_lv
logvol /home --fstype="ext4" --size=81920 --vgname=sys_vg --name=home_lv
logvol swap --fstype="ext4" --size=4096 --vgname=sys_vg --name=swap_lv
volgroup epic_vg --pesize=16384 pv.02
logvol /epic --fstype="ext4" --size=19456 --vgname=epic_vg --name=epic_lv
volgroup epicfiles_vg --pesize=16384 pv.03
logvol /epic/epicfiles --fstype="ext4" --size=29696 --vgname=epicfiles_vg --name=epicfiles_lv
volgroup tst_vg --pesize=16384 pv.04
logvol /epic/tst --fstype="ext4" --size=148480 --vgname=tst_vg --name=tst_lv
volgroup poc_vg --pesize=16384 pv.05
logvol /epic/poc --fstype="ext4" --size=60416 --vgname=poc_vg --name=poc_lv

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
