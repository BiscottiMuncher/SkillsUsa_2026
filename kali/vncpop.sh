 ### BROKEN ###
### DO NOT USE ###



## Auto pop vnc server for kali 26
## SET vncpasswd before boot

#!/bin/bash

mkdir -p ~/.vnc && touch ~/.vnc/xstartup

sudo apt-get update && sudo apt-get install tigervnc-standalone-server tigervnc-common -y

#cheat vncpasswd?
printf "skills26\skills26\n\n" | vncpasswd

## Create xstartup

cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
mkdir -p $XDG_RUNTIME_DIR
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

## Create systemctl task

sudo cat > /etc/systemd/system/vncserver@:1.service  << 'EOF'
[Unit]
Description=TigerVNC Server for display :1
After=network.target

[Service]
Type=forking
User=student
Group=student
WorkingDirectory=/home/student

PIDFile=/home/student/.vnc/%H:1.pid

ExecStartPre=-/usr/bin/vncserver -kill :1 > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :1 -geometry 1920x1080 -depth 24
ExecStop=/usr/bin/vncserver -kill :1

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

## Reload systemcstl 
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

sudo systemctl start vncserver@:1 && sudo systemctl enable vncserver@:1
