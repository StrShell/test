#!/bin/bash
yum install -y openswan

cat <<EOF >> /etc/sysctl.conf
  net.ipv4.conf.all.accept_redirects = 0
  net.ipv4.conf.all.send_redirects = 0
EOF

sysctl -p /etc/sysctl.conf

left=$(ec2-metadata -v | cut -d ' ' -f 2)

cat <<EOF > /etc/ipsec.d/aws.conf
conn Tunnel1
	authby=secret
	auto=start
	left=%defaultroute
	leftid=$left
	right=$right
	type=tunnel
	ikelifetime=8h
	keylife=1h
	phase2alg=aes128-sha1;modp1024
	ike=aes128-sha1;modp1024
#	auth=esp (제거)
	keyingtries=%forever
	keyexchange=ike
	leftsubnet=10.2.0.0/16
	rightsubnet=10.1.0.0/16
	dpddelay=10
	dpdtimeout=30
	dpdaction=restart_by_peer
 EOF

cat <<EOF > /etc/ipsec.d/aws.secrets
$left $right: PSK "password"

systemctl start ipsec
systemctl enable ipsec
