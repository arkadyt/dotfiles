#!/bin/bash

# Test your cron scripts with:
#     sudo su -
#     run-parts /etc/cron.*

LOCAL_REPORTS_DIR=/home/ubuntu/cron.reports
RECIPIENT='redacted@arkadyt.com'

export TZ='America/Los_Angeles'
mkdir -p $LOCAL_REPORTS_DIR

function write_to_file {
  local pathname=$1; shift

  if [ -f $pathname ]; then
    truncate -s 0 $pathname
  else
    touch $pathname
  fi

  for line in "$@"; do
    echo $line >> $pathname
  done
}

function compose_message {
  local date_exact=$(date +'%B %d, %Y | %H:%M:%S (%z)')
  local report=$(certbot renew -n \
        --pre-hook  "service nginx stop" \
        --post-hook "service nginx start")

  content_arr=(
    "Timestamp: $date_exact"
    "Cmd: certbot renew (w/ nginx restart)"
    "Server: $(hostname -f)"
    "Cmd result:"
    "-----------"
    "$report"
  )
}

function save_local_copy {
  local filename="$LOCAL_REPORTS_DIR/cert_renewal_report_$(date +'%Y%m%d_%H%M%S').txt"
  write_to_file $filename "${content_arr[@]}"
  local_copy_path=$filename
}

function send_email {
  local date=$(date +'%B %d, %Y')
  local header="Weekly cert update report ($date)"
  echo "" | mail -s "$header" -A $local_copy_path $RECIPIENT
}

function renew_certs {
  local content_arr
  local local_copy_path

  compose_message
  save_local_copy
  send_email
}

renew_certs

