# Create ansible project folder
rm -rf ansible2
mkdir ansible2
cd ansible2

# Create ansible.cfg file to disable host key checking (generally not a secure way to ssh, using just for the demo)
cat << EOF > ansible.cfg
[ssh_connection]
host_key_checking = False
EOF

# Dynamically get network IP of the docker network interface (change netint variable accordingly, in my case its br-10a0e22dc516)
netint=br-e0e2d0dba343
netip=$(ifconfig $netint|grep inet|sed -n 1p|awk "{print \$2}"|cut -f 1-3 -d "."|sed 's/$/.*/')

# Create the inventory.yml file which will contain the target IPs for ansible
echo "[targets]" >> inventory.yml

# Use nmap to find and extract masters' IP in the network (append it in the inventory.yml file)
echo "Finding masters' IP and appending it to inventory.yml..."
nmap -sP $netip|awk -F. '/2$/ {print $1"."$2"."$3"."$4}'| awk '{print $5}' >> inventory.yml

# create yml file with tasks for ansible to execute on master node 
cat << EOF > playground.yml
---
- hosts: targets
  remote_user: docker
  gather_facts: no
  vars:
    user: "docker"

  tasks:

    - name: Copy iptables script to remote host
      copy:
        src: ../iptables.sh
        dest: /home/docker/iptables.sh
        mode: 0755

    - name: Run script on remote host
      shell: sh /home/docker/iptables.sh
EOF

# run ansible
echo "Running Ansible"
ansible-playbook -i inventory.yml playground.yml --ask-pass --ask-become-pass 