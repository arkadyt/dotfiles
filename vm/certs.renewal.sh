#!/bin/bash

export TZ='America/Los_Angeles'

DATE=$(date +'%B %d, %Y')
DATE_PRECISE=$(date +'%B %d, %Y | %H:%M:%S (%z)')
ATTACHMENT="/home/arkadyt/cron.reports/cert_renewal_report_$(date +'%Y%m%d_%H%M%S').txt"

HEADER="Monthly cert update report ($DATE)"
OUTPUT=$(sudo certbot renew -n \
         --pre-hook  "sudo service nginx stop" \
         --post-hook "sudo service nginx start" )

BODY="DATE: $DATE_PRECISE
COMMAND: sudo certbot renew (with pre & post hooks that restart nginx)
WHERE: $(hostname -f)
REPORT: $OUTPUT"

echo "$BODY" >> $ATTACHMENT
echo "" | mail -s "$HEADER" -A $ATTACHMENT arcan770077f@gmail.com
