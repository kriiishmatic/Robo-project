#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-05e5bd14656ebdaf3"
ZONE_ID="Z0212707MY585LOOEFGA"
Domain="kriiishmatic.fun"

for instance in "$@"
do
    INSTA_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type t3.micro \
        --security-group-ids "$SG_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text)
    
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTA_ID" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text)
        Final="$instance.$Domain"   # other ec2 
    else
        IP=$(aws ec2 describe-instances \
            --instance-ids "$INSTA_ID" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text)
        Final="$Domain"             # frontend (root domain)
    fi

    echo "$instance = $IP"

    aws route53 change-resource-record-sets \
        --hosted-zone-id "$ZONE_ID" \
        --change-batch "{
            \"Comment\": \"Updating record set\",
            \"Changes\": [{
                \"Action\": \"UPSERT\",
                \"ResourceRecordSet\": {
                    \"Name\": \"$Final\",
                    \"Type\": \"A\",
                    \"TTL\": 1,
                    \"ResourceRecords\": [{
                        \"Value\": \"$IP\"
                    }]
                }
            }]
        }"
done
