# Dependencies

## Install Ansible
Example below is for CentOS 8
```
sudo dnf -y install python3-pip
sudo pip3 install --upgrade pip
pip3 install ansible --user
```

## Clone Repo
```
git clone https://github.com/lspiehler/ansible_vmware_build.git
cd ansible_vmware_build
```

## Install Dependencies
```
ansible-galaxy collection install -r collections/requirements.yml
yum install python3-pyvmomi
```

## Set environment variables
```
export VMWARE_HOST=vcenterhostname.fqdn.com
export VMWARE_USER=domain\\username
export VMWARE_PASSWORD=password
```

## Run the playbook
```
ansible-playbook -i hosts.yml site.yml
```