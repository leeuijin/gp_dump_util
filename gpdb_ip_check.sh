#!/bin/bash
PWD=`pwd -P`
echo $PWD
FILE="gpdb_ip_check.txt"

psql -t -c "select hostname,MIN(content) as content  from gp_segment_configuration where preferred_role = 'p' group by 1 order by 2;" > host.txt
cat host.txt | awk '{print $1}' |grep -v 'mdw' |grep -v 'smdw'> host2.txt
if [ -e $FILE ]; then
 rm -rf $PWD/$FILE
fi
        cat /etc/hosts |grep ' mdw' |awk '{print $2,$1}' | grep -v '#' |grep -v 'localhost' |uniq > $FILE
        cat /etc/hosts |grep ' smdw' |awk '{print $2,$1}' | grep -v '#' |grep -v 'localhost' |uniq >> $FILE
cat host2.txt  | while read line
do
    cat /etc/hosts | grep $line | awk '{print $2,$1}' | grep -v '#' | grep -v 'localhost'| uniq >> $FILE
done

cat $PWD/$FILE |grep -v "12.30.202"
rm -rf host.txt
rm -rf host2.txt
