#!/bin/bash

CONNECT_PID=""
RUNNING="" 
set VPN_HOST="vpnkcc.kcl.cl:443"
set VPN_USER="r.picon_redhat"
set VPN_PASS="Lurgd#4982j"
set FORTICLIENT_PATH="opt/forticlient-sslvpn/64bit/forticlientsslvpn_cli"
 
# Checks whether vpn is connected
function checkConnect {
    ps -p $CONNECT_PID &> /dev/null
    RUNNING=$?
}
 
# Initiates connection
function startConnect {
 
    # start vpn connection and grab its pid (expect script returns spawned vpn conn pid)
    CONNECT_PID="connect"
    eval $CONNECT_PID
}
 
# Creates an expect script to complete automated vpn connection
function connect {
 
    # write expect script to tmp location
    cat <<-EOF > /tmp/expect
        #!/usr/bin/expect -f
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
     
    #IMPORTANT!: the "EOF" just above must be preceded by a TAB character (not spaces)
 
    # lock down and execute expect script
    chmod 500 /tmp/expect
    /usr/bin/expect -f /tmp/expect
 
    # when expect script is finished (closes) clean up
    rm -f /tmp/expect
}
 
startConnect
 
