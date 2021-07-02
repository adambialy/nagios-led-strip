#!/bin/bash

WARN_S=`cat /var/log/nagios/status.dat | awk '{printf("%s",$1)}' | awk -F"servicestatus" '{i=2;while(i<=NF){print $i;i++}}' | grep -v 'scheduled_downtime_depth=1' | grep 'notifications_enabled=1' | grep 'problem_has_been_acknowledged=0' | grep 'current_state=1' | wc -l`
WARN_H=`cat /var/log/nagios/status.dat | awk '{printf("%s",$1)}' | awk -F"hoststatus" '{i=2;while(i<=NF){print $i;i++}}' | grep -v 'scheduled_downtime_depth=1' | grep 'notifications_enabled=1' | grep 'problem_has_been_acknowledged=0' | grep 'current_state=1' | wc -l`

CRIT_S=`cat /var/log/nagios/status.dat | awk '{printf("%s",$1)}' | awk -F"servicestatus" '{i=2;while(i<=NF){print $i;i++}}' | grep -v 'scheduled_downtime_depth=1' | grep 'notifications_enabled=1' | grep 'problem_has_been_acknowledged=0' | grep 'current_state=2' | wc -l`
CRIT_H=`cat /var/log/nagios/status.dat | awk '{printf("%s",$1)}' | awk -F"hoststatus" '{i=2;while(i<=NF){print $i;i++}}' | grep -v 'scheduled_downtime_depth=1' | grep 'notifications_enabled=1' | grep 'problem_has_been_acknowledged=0' | grep 'current_state=2' | wc -l`

if [ "${WARN_S}" != "0" ] || [ "${WARN_H}" != "0" ]; then
    curl -s http://192.168.1.53/cm?cmnd=Color%3A8C0004%2CHSBColor%3A358%2C100%2C55%2CChannel%3A%5B55%2C0%2C2%5D
fi

if [ "${CRIT_S}" != "0" ] || [ "${CRIT_H}" != "0" ]; then
    curl -s http://192.168.1.53/cm?cmnd=Color%3A8C0004%2CHSBColor%3A358%2C100%2C55%2CChannel%3A%5B55%2C0%2C2%5D
fi

if [ "${CRIT_S}" == "0" ] && [ "${CRIT_H}" == "0" ] && [ "${WARN_S}" == "0" ] && [ "${WARN_H}" == "0" ]; then
    curl -s http://192.168.1.53/cm?cmnd=Power%20Off
fi

