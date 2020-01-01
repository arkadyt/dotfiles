#!/bin/bash

# Test your cron scripts with:
#     sudo su -
#     run-parts /etc/cron.*

LOCAL_REPORTS_DIR=/home/ubuntu/cron.reports
EMAIL='redacted@arkadyt.com'

export TZ='America/Los_Angeles'
mkdir -p $LOCAL_REPORTS_DIR

function write_to_file {
  local pathname=$1; shift
  local contents=("$@")

  if [ -f $pathname ]; then 
    truncate -s 0 $pathname
  else
    touch $pathname
  fi

  echo ${contents[@]} | sed "s/ /\n/g" > $pathname
}

function compose_message {
  local date_exact=$(date +'%B %d, %Y | %H:%M:%S (%z)')
  local report=$(certbot renew -n \
           --pre-hook  "service nginx stop" \
           --post-hook "service nginx start" )

  local message=(
    "Timestamp: $date_exact"
    "Cmd: certbot renew (w/ nginx restart)"
    "Server: $(hostname -f)"
    "Cmd result:"
    "-----------"
    "$report"
  )

  return $message
}

function save_local_copy {
  local filename="$LOCAL_REPORTS_DIR/cert_renewal_report_$(date +'%Y%m%d_%H%M%S').txt"
  write_to_file $filename $1
}

function send_email {
  local date=$(date +'%B %d, %Y')
  local header="Weekly cert update report ($date)"
  echo "" | mail -s "$header" -A $1 $EMAIL
}

function renew_certs {
  compose_message; content_arr=$?
  save_local_copy $content_arr
  # send_email $content_arr
}

renew_certs
