#!/bin/bash

echo 'project,instance,zone,machine_type' >> ./running_instances.csv
gcloud projects list | cut -f1 -d ' ' | grep -v '^PROJECT_ID' | while read -r p
do
    COUNT=`echo 'N' | gcloud compute instances list --project $p --filter="status:( running )" | wc -l`
    if [ 1 -lt ${COUNT} ] ; then
        echo 'N' | gcloud compute instances list --project $p --filter="status:( running )" | grep -v '^NAME' | awk -v OFS=, -v p="$p" '{$8=p; print $8,$1,$2,$3}' >> ./running_instances.csv
    fi
done

python check_instances.py
cat disallowed_instances.csv | column -t -s"," | ./send_slack.sh
