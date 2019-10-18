#!/usr/bin/env bash
###########################################################################
#
# Created by bublik77 for CryptoLions.io
# CryptoLions.io
#
# Checking SSL end status
# Home: cryptolions.io
###########################################################################

MAIL="/usr/sbin/ssmtp" #you should have been configured ssmtp 
STATUS_FILE="./STATUS_SSL.txt"
DOMAINS="./DOMAINS.txt"

[ -s $STATUS_FILE ] && echo -e "" $STATUS_FILE;

send_report(){
	if [[ -s $STATUS_FILE ]]
	then
		echo -e "Subject: SSL ended soon!\n\n$(cat $STATUS_SSL)" | $MAIL name@your.domain
	fi
}

check_date() {
	DATE_TODAY=$(date -d "$(date '+%b %d %Y')" +%s)
	DAY_EXPIERED=$(echo | openssl s_client -servername $1 -connect $(host $1 | head -1 | cut -d" " -f4):443 2>/dev/null | openssl x509 -noout -dates | tail -1 | cut -d"=" -f2 | awk '{print $1" "$2}' | date -d "$(xargs)" +%s)
	DAY_LEFT=$(echo $DAY_EXPIERED - $DATE_TODAY | bc | date --date=@$(xargs) +'%m,%d ' | cut -d"," -f2 | echo "$(xargs) * 1" | bc) # multiply by one to know that is a number =)
	MONTH_LEFT=$(echo $DAY_EXPIERED - $DATE_TODAY | bc | date --date=@$(xargs) +'%m,%d ' | cut -d"," -f1 | echo "$(xargs) - 1" | bc) #I subtract 1 in order to do not count present month
	if [[ $MONTH_LEFT -eq 1 ]] && [[ $DAY_LEFT -le 5 ]]
	then
		echo -e "It looks SSL for domain $1 is ended soon, is left $MONTH_LEFT month and $DAY_LEFT days\n" >> $STATUS_FILE
	elif [[ $MONTH_LEFT -eq 0 ]]
	then
		echo -e "It looks SSL for domain $1 is ended very soon, $DAY_LEFT days\n" >> $STATUS_FILE
	fi
}

while read line
do
	check_date $line
done < $DOMAINS

send_report
exit 0