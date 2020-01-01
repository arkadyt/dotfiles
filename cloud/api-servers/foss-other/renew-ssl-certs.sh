#!/bin/bash

# Test your cron scripts with:
#     sudo su -
#     run-parts /etc/cron.*

export TZ='America/Los_Angeles'

DATE=$(date +'%B %d, %Y')
DATE_PRECISE=$(date +'%B %d, %Y | %H:%M:%S (%z)')

ATTACHMENT="/home/arkadyt/cron.reports/cert_renewal_report_$(date +'%Y%m%d_%H%M%S').txt"
EMAIL='redacted@arkadyt.com'

HEADER="Weekly cert update report ($DATE)"
OUTPUT=$(certbot renew -n \
         --pre-hook  "service nginx stop" \
         --post-hook "service nginx start" )

BODY="DATE: $DATE_PRECISE
COMMAND: certbot renew (with pre & post hooks that restart nginx)
WHERE: $(hostname -f)
REPORT: $OUTPUT"

echo "$BODY" >> $ATTACHMENT
echo "" | mail -s "$HEADER" -A $ATTACHMENT $EMAIL