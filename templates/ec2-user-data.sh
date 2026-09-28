#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# 패키지 업데이트
apt-get update -y

# NAT 규칙 저장용
apt-get install -y iptables-persistent

# -----------------------------------------------------------------------------
# IP Forwarding 활성화
# -----------------------------------------------------------------------------

cat <<EOF > /etc/sysctl.d/99-nat-instance.conf
net.ipv4.ip_forward=1
EOF

sysctl --system

# -----------------------------------------------------------------------------
# NAT 설정
# -----------------------------------------------------------------------------

# 기본 외부 인터페이스 자동 검색
PRIMARY_INTERFACE=$(ip route | awk '/default/ {print $5; exit}')

# 기존 NAT 규칙 중 동일 규칙이 없을 때만 추가
iptables -t nat -C POSTROUTING -o "$PRIMARY_INTERFACE" -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o "$PRIMARY_INTERFACE" -j MASQUERADE

# Forward 허용
iptables -C FORWARD -i "$PRIMARY_INTERFACE" -m state \
  --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -i "$PRIMARY_INTERFACE" -m state \
  --state RELATED,ESTABLISHED -j ACCEPT

iptables -C FORWARD -o "$PRIMARY_INTERFACE" -j ACCEPT 2>/dev/null || \
iptables -A FORWARD -o "$PRIMARY_INTERFACE" -j ACCEPT

# 재부팅 후에도 유지
netfilter-persistent save

echo "NAT instance initialization complete"
sysctl net.ipv4.ip_forward
iptables -t nat -L -n -v