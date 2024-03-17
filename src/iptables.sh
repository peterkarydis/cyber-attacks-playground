# Run this while DDoS attack is running

# Security risk: We are saving sudo password inside a bash script. This is only done for demo purposes
echo "docker"|sudo -S sudo -S true

sudo apt update
sudo apt upgrade -y

# reseting IP tables from past config
sudo iptables -F

# creating new user-defined chain named icmp_flood
sudo iptables -N icmp_flood
sudo iptables -A INPUT -p icmp -j icmp_flood
# This way we limit the ICMP packets to 1/s and burst to 3 packets
sudo iptables -A icmp_flood -m limit --limit 1/s --limit-burst 3 -j RETURN
sudo iptables -A icmp_flood -j DROP