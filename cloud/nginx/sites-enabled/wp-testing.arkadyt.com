server {
    listen                     80;
    listen                [::]:80;
    server_name           wp-testing.arkadyt.com;

    location / {
        proxy_read_timeout     90;
        proxy_connect_timeout  90;
        proxy_redirect         off;
        proxy_pass             http://0.0.0.0:5002;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Host $server_name;
    }
}
