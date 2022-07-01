#!/usr/bin/env bash

set -e

VERSION=4.5.0

#if ! command -v code-server &> /dev/null
#then
#    echo "code-server could not be found"
#    exit
#fi

if ! type -P code-server
then 

    echo -e "\n===================\nInstall code-server...\n================="    

    # install code-server
    wget https://github.com/cdr/code-server/releases/download/v${VERSION}/code-server_${VERSION}_$(dpkg --print-architecture).deb && \
    sudo dpkg -i code-server_${VERSION}_$(dpkg --print-architecture).deb && \
    rm -f code-server_${VERSION}_$(dpkg --print-architecture).deb

<<'###'
# install supervisor
sudo apt update && sudo apt install -y \
    supervisor \
    wget

sudo service supervisor restart



echo -e "\n===================\nConfiguring code-server ...\n================="

sudo touch /etc/supervisor/conf.d/code-server.conf

sudo cat > "/etc/supervisor/conf.d/code-server.conf" <<EOF
[program:code-server]
command=code-server --bind-addr 0.0.0.0:9889 --auth none
user=%(ENV_USER)s
autostart=true
autorestart=true
stopwaitsecs=30
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
}
EOF

sudo supervisorctl reread && supervisorctl update
###

echo -e "\n===================\nInstall code-server complete...\n================="    
                                                  
fi   

#run code-server
#nohup code-server --bind-addr 0.0.0.0:9889 --cert --auth none & 
#cat nohup.out

code-server --bind-addr 0.0.0.0:12345 --cert --auth none
