%pre
#!/bin/bash
if [ -b /dev/vda ] ; then
	DISK="vda"
elif [ -b /dev/hda ] ; then
	DISK="hda"
else
	DISK="sda"
fi

echo "ignoredisk --only-use=${DISK},sdb" > /tmp/onlyuse
echo "bootloader --location=mbr --boot-drive=${DISK} --append=\"console=tty0 console=ttyS0,119200n8\"" > /tmp/bootloader
echo "part pv.01 --grow --ondisk=${DISK}" > /tmp/part

%end

install
lang en_US.UTF-8

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
part pv.02 --grow --onpart=sdb
#part pv.03 --size=1 --grow --ondisk=sdc
#part pv.04 --size=1 --grow --ondisk=sdd
#part pv.05 --size=1 --grow --ondisk=sde
#part pv.01 --size=1 --grow --ondisk=${DISK}
volgroup sys_vg --pesize=16384 pv.01
#logvol /boot --fstype="xfs" --size=1024 --vgname=sys_vg --name=boot_lv
logvol / --fstype="xfs" --size=15360 --vgname=sys_vg --name=root_lv
#logvol /usr --fstype="xfs" --size=10240 --vgname=sys_vg --name=usr_lv
#logvol /var --fstype="xfs" --size=5120 --vgname=sys_vg --name=var_lv
#logvol /opt --fstype="xfs" --size=2048 --vgname=sys_vg --name=opt_lv
#logvol /epic_core --fstype="xfs" --size=5120 --vgname=sys_vg --name=epic_core_lv
logvol /home --fstype="xfs" --size=4096 --vgname=sys_vg --name=home_lv
logvol swap --fstype="swap" --size=4096 --vgname=sys_vg --name=swap_lv
volgroup app_vg --pesize=16384 pv.02
logvol /var/cache/pulp --fstype="xfs" --size=20480 --vgname=app_vg --name=var_cache_pulp_lv
logvol /var/lib/pulp --fstype="xfs" --size=102400 --vgname=app_vg --name=var_lib_pulp_lv
logvol /var/lib/mongodb --fstype="xfs" --size=51200 --vgname=app_vg --name=var_lib_mongodb_lv
logvol /var/log --fstype="xfs" --size=10240 --vgname=app_vg --name=var_log_lv
logvol /var/opt/rh/rh-postgresql12 --fstype="xfs" --size=10240 --vgname=app_vg --name=var_opt_rh_rh-postgresql12_lv
logvol /var/spool/squid --fstype="xfs" --size=10240 --vgname=app_vg --name=var_spool_squid_lv
#volgroup epicfiles_vg --pesize=16384 pv.03
#logvol /epic/epicfiles --fstype="xfs" --size=29696 --vgname=epicfiles_vg --name=epicfiles_lv
#volgroup tst_vg --pesize=16384 pv.04
#logvol /epic/tst --fstype="xfs" --size=148480 --vgname=tst_vg --name=tst_lv
#volgroup poc_vg --pesize=16384 pv.05
#logvol /epic/poc --fstype="xfs" --size=60416 --vgname=poc_vg --name=poc_lv

rootpw --iscrypted $6$vMXfFeQNEgDGy5.7$2hublUvL7txrLv.GSzNd5UYVnR/KtHL2PLosJ.TQxRC/rknq53StzaZXwK03OyjtaHzdRkvq6Fybfbl/pYYtT.

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
