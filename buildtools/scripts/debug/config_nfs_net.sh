#!bin/sh

iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
udhcpc eth0 -s /www/pages/conf/udhcpc.conf
brctl delbr br0
ip route del default
ip route add default via 192.168.0.1 dev eth0
echo All default!!!