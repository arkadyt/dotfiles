## nginx/sites-available/api.arkadyt.com
 * /etc
 * `nginx` reverse proxy config for virtual host api.arkadyt.com
 * enables HTTPS
 * redirects incoming requests to different `docker` containers running in the system

## nginx/nginx.conf
 * /etc
 * global nginx config
 * static content delivery is not optimized (serving only application/json)
 * gzips every resource to save on GCP egress traffic quota

## postfix/main.cf
 * /etc
 * `postfix` mail server config
 * enables outgoing mail service through sendgrid smtp relay servers on google compute engine vm instances (GCP blocks smtp ports 25, 465 and 587)
 * used with mailx from `mailutils`

## certs.renewal.sh
 * /etc/cron.monthly/
 * monthly ssl certificates renewal through a cron job
 * uses `certbot` certificate manager
 * reports operation status through email
 * requires cron.reports folder in home/user directory

## spinup/
 * spin-up scripts for docker containers

## more
 * https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/ 
 * https://letsencrypt.org/ 
 * https://certbot.eff.org/ 
 * https://cloud.google.com/compute/docs/tutorials/sending-mail/using-sendgrid
