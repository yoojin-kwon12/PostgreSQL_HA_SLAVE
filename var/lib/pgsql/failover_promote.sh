#!/bin/bash
up_id=$1
name=$2
if [ $name == 'standby_promote' ]; then
declare -A servers
if [ $up_id == 1 ] ; then
        down_id=2
else
        down_id=1
fi
servers[2]="192.168.176.177"
servers[1]="192.168.176.175"
while [[ `(ssh -o ConnectTimeout=5 ${servers[$down_id]} echo ok 2>&1)` != 'ok' ]]
do
sleep 2
echo Failed node ${servers[$down_id]} is not reachable## >> /var/log/repmgr/repmgrd.log
done
ssh -T postgres@${servers[$down_id]} << EOF
 sleep 5
 sudo systemctl stop postgresql-14.service && sleep 10
 rm -rf /var/lib/pgsql/14/data
 repmgr -h ${servers[$up_id]} -d repmgr -U repmgr standby clone --force &&
 sudo systemctl start postgresql-14.service && sleep 2
 repmgr standby register -F
EOF
echo ${servers[$up_id]}
fi

