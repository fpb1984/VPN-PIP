#!/bin/bash
CONNECT_PID=""
RUNNING="" 
VPN_HOST="vpnkcc.kcl.cl:443"
VPN_USER="r.picon_redhat"
VPN_PASS="Lurgd#4982j"
FORTICLIENT_PATH="opt/forticlient-sslvpn/64bit/forticlientsslvpn_cli"

function checkConnect {
	ps -p $CONNECT_PID &> /dev/null
	RUNNING=$?
}

function startConnect {
	CONNECT_PID="connect"
	eval $CONNECT_PID
}

# Creates an expect script to complete automated vpn connection
function connect {
     cat <<-EOF > /tmp/expect
        match_max 1000000
        set timeout -1
        spawn $FORTICLIENT_PATH --server $VPN_HOST --vpnuser $VPN_USER --keepalive
        puts [exp_pid]
        expect "Password for VPN:"
        send -- "$VPN_PASS"
        send -- "\r"
        expect "Would you like to connect to this server? (Y/N)"
        send -- "Y"
        send -- "\r"
        expect "Clean up..."
        close
	EOF
    chmod 500 /tmp/expect
    /usr/bin/expect -f /tmp/expect
    rm -f /tmp/expect
}
startConnect
