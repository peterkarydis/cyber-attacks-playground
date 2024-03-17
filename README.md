# Cyber attacks playground

Projects' goal is to test multiple cyber attack concepts in a simulated production environment.

## Docker Installation (inside a kali VM)
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
```
sudo apt install -y docker-ce
 echo   "or"
sudo apt install docker*
```
- check if docker deamon is running
```
sudo systemctl status docker
```
- change docker user, docker should not be run as root (change username accordingly)
```
sudo usermod -aG docker username
```
- log out and in again, for changes to apply

### Docker compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
```
sudo chmod +x /usr/local/bin/docker-compose
```
```
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
- get the docker images' repo keys from projects' server (in this case my lab teacher, cannot share them for obvious reasons)

### Clone swarmlab repo
- The project is based on swarmlab, which is based on docker.
```
git clone https://git.swarmlab.io:3000/swarmlab/swarmlab-sec
```
```
cd swarmlab-sec/
```
- In here we can create project directories

### Create docker swarm
```
mkdir cybersec
```
```
cd cybersec
```
```
../install/usr/share/swarmlab.io/sec/swarmlab-sec create
```
- choose swarm size (in this case 10)
```
../install/usr/share/swarmlab.io/sec/swarmlab-sec up size=10
```
![containers_created](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic1.png?raw=true)
![docker_ps](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic2.png?raw=true)

- in case you want to shutdown cluster
```
../install/usr/share/swarmlab.io/sec/swarmlab-sec down
```
- in case max depth is exceeded for your namespace, run
```
docker rmi -f $(docker images -a -q)
```
## DDoS Attack (Ping flood)
- In this concept we will orchestrate a ping flood DDoS attack against a specific IP inside the swarm by running a script inside the docker containers with ansible
- We are using 2 scripts: ddos.sh which runs the whole attack, and flood.sh which is the script that will be copied and run inside each docker container
- Inside project folder we run:
```
../install/usr/share/swarmlab.io/sec/swarmlab-sec login
```
to login to master node. Inside master we run tcpdump to capture ICMP packets:
```
sudo timeout 2s tcpdump -i eth0 icmp and src 172.27.0.2 and dst net 172.27.0.0/16
```
- We see no packet traffic
- We initiate the attack by running ddos.sh
![ddos_run](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic3.png?raw=true)
- SSH password is docker
![ansible_1](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic4.png?raw=true)
![ansible_2](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic5.png?raw=true)
- The DDoS attack loop is running, inside master we capture packets running:
```
sudo timeout 2s tcpdump -i eth0 icmp and src 172.27.0.2 and dst net 172.27.0.0/16
```
- The reason we monitor traffic from and not to master node is because of the firewall in between (for a clear view of packet count)
![ddos_running](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic6.png?raw=true)
- ICMP packets are coming from every IP inside the network in flood mode.
### Countermeasures
- We use iptables inside master node to limit the ICMP packets he receives
- We run ddos_shield.sh to setup a new iptables rule set inside master node.
![ddos_shield](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic7.png?raw=true)
- After rule set is applied, we monitor traffic again:
```
sudo timeout 2s tcpdump -i eth0 icmp and src 172.27.0.2 and dst net 172.27.0.0/16
```
![iptables_applied](https://github.com/peterkarydis/cyber-attacks-playground/blob/main/images/pic8.png?raw=true)
