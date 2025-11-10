#!/bin/bash
set -e

NGINX_DIR="/opt/homebrew/etc/nginx"
WWW_DIR="/opt/homebrew/var/www"

sudo mkdir -p $NGINX_DIR/{sites-available,sites-enabled,ssl}
sudo mkdir -p $WWW_DIR/{alpha.local,beta.local}/html

echo "<h1>Welcome to Alpha</h1>" | sudo tee $WWW_DIR/alpha.local/html/index.html
echo "<h1>Welcome to Beta</h1>" | sudo tee $WWW_DIR/beta.local/html/index.html
sudo chown -R $(whoami):staff $WWW_DIR
sudo chmod -R 755 $WWW_DIR

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=alpha.local" \
  -keyout $NGINX_DIR/ssl/alpha.local.key \
  -out $NGINX_DIR/ssl/alpha.local.crt

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/CN=beta.local" \
  -keyout $NGINX_DIR/ssl/beta.local.key \
  -out $NGINX_DIR/ssl/beta.local.crt

# alpha.local
sudo tee $NGINX_DIR/sites-available/alpha.local >/dev/null <<CONF
server {
    listen 8081;
    server_name alpha.local;
    return 301 https://\$host:8443\$request_uri;
}

server {
    listen 8443 ssl;
    server_name alpha.local;

    ssl_certificate     $NGINX_DIR/ssl/alpha.local.crt;
    ssl_certificate_key $NGINX_DIR/ssl/alpha.local.key;

    root $WWW_DIR/alpha.local/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /docs/ {
        alias $WWW_DIR/alpha.local/html/files/documents/;
    }
}
CONF

# beta.local
sudo tee $NGINX_DIR/sites-available/beta.local >/dev/null <<CONF
server {
    listen 8082;
    server_name beta.local;
    return 301 https://\$host:8444\$request_uri;
}

server {
    listen 8444 ssl;
    server_name beta.local;

    ssl_certificate     $NGINX_DIR/ssl/beta.local.crt;
    ssl_certificate_key $NGINX_DIR/ssl/beta.local.key;

    root $WWW_DIR/beta.local/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
CONF

sudo ln -sf $NGINX_DIR/sites-available/alpha.local $NGINX_DIR/sites-enabled/
sudo ln -sf $NGINX_DIR/sites-available/beta.local $NGINX_DIR/sites-enabled/

mkdir -p $WWW_DIR/alpha.local/html/files/documents
echo "Deep file" | tee $WWW_DIR/alpha.local/html/files/documents/longfile.html

grep -q "alpha.local" /etc/hosts || echo "127.0.0.1 alpha.local" | sudo tee -a /etc/hosts
grep -q "beta.local" /etc/hosts || echo "127.0.0.1 beta.local" | sudo tee -a /etc/hosts

sudo nginx -t
sudo nginx -s reload || sudo nginx

echo ""
echo " http://alpha.local:8081  → редирект на https://alpha.local:8443"
echo " http://beta.local:8082   → редирект на https://beta.local:8444"
echo " https://alpha.local:8443/docs/longfile.html"
