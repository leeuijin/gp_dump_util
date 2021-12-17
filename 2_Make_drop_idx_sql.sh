#!/bin/bash
##########################################################################################
# DROP INDEX                                                                             #
##########################################################################################
OUTPUT_FILE="drop_index.sql"

StartTime=$(date +%s)

rm $OUTPUT_FILE
touch 1.txt
i=1
while read line || [ -n "$line" ] ; do
case "$line" in *"CREATE INDEX"*)
echo "$line" | awk '{print $3 }' |sed s/^/"DROP INDEX "/g |sed s/$/" ;"/g >> $OUTPUT_FILE
;;
esac
case "$line" in *"CREATE UNIQUE INDEX"*)
echo "$line" | awk '{print $4 }' |sed s/^/"DROP INDEX "/g |sed s/$/" ;"/g >> $OUTPUT_FILE
;;
esac
case "$line" in *search_path*)
echo "$line" >> $OUTPUT_FILE
;;
esac
case "$line" in *--*)
echo "removed joosuk & blank"
;;
esac
case "$line" in *"ALTER TABLE ONLY "*)
echo "$line" | awk '{print $4 }' |sed s/^/"ALTER TABLE "/g |sed s/$/" DROP PRIMARY KEY ;"/g >> $OUTPUT_FILE
;;
esac
  ((i+=1))
done < CRT_INDEX.sql

EndTime=$(date +%s)
echo "It takes $(($EndTime - $StartTime)) seconds to complete this task."
echo ""
echo "Please Check $OUTPUT_FILE"
echo "work complet."
