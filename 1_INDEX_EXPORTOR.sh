#!/bin/bash
##########################################################################################
#ENV                                                                                     #
##########################################################################################
export LANG=ko_KR.utf8
BACKUP_PATH="/backup/imsi-DCA-01/db_dumps/20211202"
CUR_PATH=`pwd`
th="8"

cd $BACKUP_PATH
##########################################################################################
#PREPARE
##########################################################################################
find -name "gp_cdatabase*" | xargs grep -i 'CREATE DATABASE' |awk '{print $1, $3}' |sed 's/..gp_cdatabase_-1_1_//'|sed 's/CREATE/ /'|sed 's/://' > $CUR_PATH/DB_NM_LIST.txt
cat $CUR_PATH/./DB_NM_LIST.txt
echo ""
echo "Enter the Time Sequence Number name: "
#20211202003003
read TSN
echo "NUMBER: $TSN"
DB_NM=$(grep $TSN $CUR_PATH/DB_NM_LIST.txt |awk '{print $2}')
#DB_NM=`cat DB_NM_LIST.txt |grep $TSN |awk '{print $2}'`
echo "DATABASE NAME : $DB_NM "

##########################################################################################

FILE_NM=$(ls "gp_dump_-1_1_"$TSN"_post_data.gz" |tail -1 |sed -n '1p')
OUTPUT_FILE_NM=`echo "$FILE_NM"  |sed 's/gz/sql/'`
gzip -dc  $FILE_NM > $CUR_PATH'/'$OUTPUT_FILE_NM
echo ""
echo "please check total_ddl_file_name = `echo $CUR_PATH'/'$OUTPUT_FILE_NM`"
echo ""

cd $CUR_PATH
#cat $OUTPUT_FILE_NM |grep -A 2 -E "SET |ALTER TABLE ONLY| INDEX" > CRT_INDEX_ALL.sql
grep -A 2 -E "SET |ALTER | INDEX" $OUTPUT_FILE_NM > CRT_INDEX.sql

#Dvided file by search_path 
csplit -z -f "SPLIT" CRT_INDEX.sql '/search_path/' '{*}'



##########################################################################################
# Multi_THREAD_EXECUTE                                                                   #
##########################################################################################
StartTime=$(date +%s)

for file in $CUR_PATH/SPLIT*
  do j_count=`jobs -l|wc|awk '{print $1}'`
  if [[ $j_count -ge $th ]];then
    until [[ $j_count -lt $th ]]
      do j_count=`jobs -l|wc|awk '{print $1}'`
      sleep 0.1
      done
  fi
  echo ${file}
  psql -d $DB_NM -f ${file}  > /dev/null 2>&1 &
  sleep 0.1
  done

lastPIDs=`jobs -l|awk '{print $2}'`
wait $lastPIDs
EndTime=$(date +%s)
echo ""
  echo "It takes $(($EndTime - $StartTime)) seconds to complete this task."
echo ""
echo "work complete."
