# Requirements

* Ubuntu server

# Instructions

## SSH

Change the default ssh port and disable root login

	sudo vi /etc/ssh/sshd_config
    Set Port [custom ssh port number]
	Set PermitRootLogin no
    
Restart the ssh service

	sudo /etc/init.d/ssh restart
    
Update firewall rules now to enable ssh connection with your custom port

Reconnect your ssh host with the new port number
    
    ssh -p [custom ssh port number] user@host
    
## Fail2Ban

Install Fail2Ban

	sudo apt-get install fail2ban
    
Copy the configuration file

	sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    
Edit the config file

	sudo vi /etc/fail2ban/jail.local
    
Make the following changes:

	[ssh]
	port     = [custom ssh port number]

And

	[ssh-ddos]
    enabled  = true
    port     = [custom ssh port number]

Finish editing and restart fail2ban service

	sudo service fail2ban restart

## Network

Edit the network configuration file

	sudo vi /etc/sysctl.conf

Paste the this configuration file to improve network security

```
#
# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables
# See sysctl.conf (5) for information.
#

# Uncomment the next two lines to enable Spoof protection (reverse-path filter)
# Turn on Source Address Verification in all interfaces to
# prevent some spoofing attacks
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

# Uncomment the next line to enable TCP/IP SYN cookies
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Do not accept ICMP redirects (prevent MITM attacks)
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0 
net.ipv6.conf.default.accept_redirects = 0

# Do not send ICMP redirects (we are not a router)
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Do not accept IP source route packets (we are not a router)
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Log Martian Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Ignore ICMP broadcast requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore Directed pings
net.ipv4.icmp_echo_ignore_all = 1
```