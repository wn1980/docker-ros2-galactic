# Refs:
# https://github.com/FiloSottile/mkcert
# https://github.com/coder/code-server/issues/5162#issuecomment-1214183806

#!/usr/bin/env bash

set -e

if [ $(uname -m) == 'x86_64' ]
then
    ARCH=amd64
elif [ $(uname -m) == 'aarch64' ] 
then 
    ARCH=arm64
else
    echo 'not matched platform!'
    exit 0
fi

mkdir -p ~/.config/code-server
cd ~/.config/code-server
wget https://dl.filippo.io/mkcert/latest?for=linux/${ARCH} -O ./mkcert
chmod +x mkcert
sudo mv -f mkcert /usr/local/bin/mkcert

mkcert -install
mkcert your_machine_ip 127.0.0.1

cat > "./config.yaml" <<EOF
bind-addr: 127.0.0.1:8080
auth: password
password: 8fb2e56be5f89ed61780671c
cert: .config/code-server/your_machine_ip+1.pem
cert-key: .config/code-server/your_machine_ip+1-key.pem

EOF

cat > "/app/conf.d/code-server.conf" <<EOF
[program:code-server]
#command=code-server --bind-addr 0.0.0.0:8008 --cert --auth none 
command=code-server --bind-addr 0.0.0.0:8008 --auth none 
user=developer
autostart=true
autorestart=true
stopwaitsecs=30
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

EOF
