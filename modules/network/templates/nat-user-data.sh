#!/bin/bash

# EIP association and repository availability can lag instance launch.
retry() {
  local attempt
  for attempt in $(seq 1 30); do
    if "$@"; then
      return 0
    fi
    sleep 10
  done
  return 1
}

retry dnf install -y iptables-services

cat > /etc/sysctl.d/99-nat.conf <<'SYSCTL'
net.ipv4.ip_forward = 1
SYSCTL
sysctl -p /etc/sysctl.d/99-nat.conf

# AL2023/Nitro may name the interface ens5 or enX0 instead of eth0.
INTERFACE=$(ip -4 route show default | awk 'NR == 1 {print $5}')
test -n "$INTERFACE"

# Persist all rules through iptables-services so a reboot restores NAT.
# The EC2 security group controls SSH and allowed subnet sources.
cat > /etc/sysconfig/iptables <<RULES
*filter
:INPUT ACCEPT [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A FORWARD -s ${vpc_cidr} -o $INTERFACE -j ACCEPT
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s ${vpc_cidr} -o $INTERFACE -j MASQUERADE
COMMIT
RULES

systemctl enable iptables
systemctl restart iptables
iptables -t nat -L POSTROUTING -n -v
echo "NAT instance initialization complete"
