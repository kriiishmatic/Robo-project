#!/bin/bash
#colours
#####################

mongodIP="mongodb.kriiishmatic.fun"


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo -e " $R Get sudo access BOZO $N "
    exit 3
fi


#creating logs files
####################

shell_log="/var/log/robo-project"

mkdir -p $shell_log

#removing .sh from file
#######################

Remove_sh=$( echo $0 | cut -d "." -f1 )

Logfile="$shell_log/$Remove_sh.log"
DIR=$(pwd)

echo " Script started at :: $(date) " | tee -a $Logfile


Status(){
    if [ $1 -ne 0 ]; then
    echo -e " $R Failed $N  $2  " | tee -a $Logfile
    exit 1
else
    echo -e "$G Sucessfully $N $2 " | tee -a $Logfile
fi
}

####### NODEJS ######

dnf module disable nodejs -y &>>$Logfile
Status $? "Disabled the node"

dnf module enable nodejs:20 -y 
Status $? "enabled the node"
dnf install nodejs -y &>>$Logfile
Status $? "installed the node"

id roboshop &>>$Logfile
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    else
    echo -e " Already installed $Y SKIPPED! $N "
fi

mkdir -p /app 
Status $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
Status $? "Dowloadting code zip"


cd /app 
rm -rf /app/*
Status $? "Removed previous code"

unzip /tmp/catalogue.zip &>>$Logfile
Status $? "unzipping latest code"

cd /app 

npm install &>>$Logfile
Status $? "installed the DEPENDENCIES"

cp $DIR/catalogue.service /etc/systemd/system/catalogue.service
Status $? "Copied catalogue service"

systemctl daemon-reload
Status $? "Demonic reload"

systemctl enable catalogue &>>$Logfile
Status $? "Enabled the node"

systemctl start catalogue &>>$Logfile
Status $? "Start it "

cp $DIR/mongo.repo /etc/yum.repos.d/mongo.repo
Status $? "Mongo repo is here"

dnf install mongodb-mongosh -y &>>$Logfile
Status $? "installed the mongoin in catalogue "

INDEX=$(mongosh mongodb.kriiishamtic.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") #### this one gives you a value 0 and nehatice
if [ $INDEX -le 0 ]; then
mongosh --host $mongodIP </app/db/master-data.js
    else
echo -e " Already loaded products and masterdata so $Y skipping $N "
fi


systemctl restart catalogue &>>$Logfile
Status $? "Restarted the service"

echo -e " Loading products into DB and $G restarted the catalogue $N "

telnet -lntp 
Status $? "Checking the Ports"

http://localhealth:8080/
Status $? "Node health"


