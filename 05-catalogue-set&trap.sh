#!/bin/bash
#colours
#####################

mongodIP="mongod.kriiishmatic.fun"


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

########## NODEJS ##########
echo -e "Installing $G NodeJS $N "

dnf module disable nodejs -y &>>$Logfile
dnf module enable nodejs:20 -y 
dnf install nodejs -y &>>$Logfile

id roboshop &>>$Logfile
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    else
    echo -e " Already installed $Y SKIPPED! $N "
fi

mkdir -p /app 
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
rm -rf /app/*

unzip /tmp/catalogue.zip &>>$Logfile

cd /app 

npm install &>>$Logfile

########## ccreating service ################
echo -e " $G creating catalogue service $N "

cp $DIR/catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload

systemctl enable catalogue &>>$Logfile

systemctl start catalogue &>>$Logfile

cp $DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$Logfile

INDEX=$(mongosh mongod.kriiishamtic.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") #### this one gives you a value 0 and nehatice
if [ $INDEX -le 0 ]; then
mongosh --host $mongodIP </app/db/master-data.js
    else
echo -e " Already loaded products and masterdata so $Y skipping $N "
fi

systemctl restart catalogue &>>$Logfile

echo -e " Loading products into DB and $G restarted the catalogue $N "


