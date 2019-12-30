server {
    listen                443 ssl; 
    server_name           apis.arkadyt.com;

    ssl_certificate       /etc/letsencrypt/live/apis.arkadyt.com/fullchain.pem; 
    ssl_certificate_key   /etc/letsencrypt/live/apis.arkadyt.com/privkey.pem; 

    include               /etc/letsencrypt/options-ssl-nginx.conf; 
    ssl_dhparam           /etc/letsencrypt/ssl-dhparams.pem; 

    location /wework/ {
        proxy_pass        http://0.0.0.0:5001/;
    }
    location /vspace/ {
        proxy_pass        http://0.0.0.0:5003/;
    }
    location = / {
        return 404;
    }
}

server {
    listen        80;
    server_name   apis.arkadyt.com;

    if ($host = apis.arkadyt.com) {
        return 301 https://$host$request_uri;
    } 
}
