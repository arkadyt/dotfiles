server {
    listen                443 ssl; 
    server_name           api.arkadyt.com;

    ssl_certificate       /etc/letsencrypt/live/api.arkadyt.com/fullchain.pem; 
    ssl_certificate_key   /etc/letsencrypt/live/api.arkadyt.com/privkey.pem; 

    include               /etc/letsencrypt/options-ssl-nginx.conf; 
    ssl_dhparam           /etc/letsencrypt/ssl-dhparams.pem; 

    location /wnetb/ {
        proxy_pass http://0.0.0.0:5001/;
    }

    location = / {
        return 404;
    }
}

server {
    listen        80;
    server_name   api.arkadyt.com;

    if ($host = api.arkadyt.com) {
        return 301 https://$host$request_uri;
    } 
}
