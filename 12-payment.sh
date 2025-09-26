#!/bin/bash
#colours
#####################

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)

if [ $USERID -ne 0 ]; then
    echo -e " $R Get sudo access BOZO $N "
    exit 3
fi
MysqlDomian="mysql.kriiishmatic.fun"

#creating logs files
####################

shell_log="/var/log/robo-project"

mkdir -p $shell_log

#removing .sh from file
#######################

Remove_sh=$( echo $0 | cut -d "." -f1 )

Logfile="$shell_log/$Remove_sh.log"
DIR=$PWD

echo " Script started at :: $(date) " | tee -a $Logfile
Start=$( date +%s )
Status(){
    if [ $1 -ne 0 ]; then
    echo -e " $R Failed $N  $2  " | tee -a $Logfile
    exit 1
else
    echo -e "$G Sucessfully $N $2 " | tee -a $Logfile
fi
}

####### NODEJS ######

dnf install python3 gcc python3-devel -y &>>$Logfile

id roboshop &>>$Logfile
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    else
    echo -e " Already installed $Y SKIPPED! $N "
fi


mkdir -p /app 
Status $? "Creating directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$Logfile
Status $? "Dowloading code zip"


cd /app 
rm -rf /app/*
Status $? "Removed previous code"

unzip /tmp/payment.zip &>>$Logfile
Status $? "unzipping latest code"

cd /app 

pip3 install -r requirements.txt &>>$Logfile
Status $? "Installed dependencies for Python"

cp $DIR/payment.service /etc/systemd/system/payment.service
Status $? "Copied payment service"

systemctl daemon-reload &>>$Logfile
Status $? "Demonic reload"

systemctl enable payment &>>$Logfile
Status $? "Enabled the node"

systemctl start payment &>>$Logfile
Status $? "Start it "

systemctl restart payment &>>$Logfile
Status $? "Restarted the service"

echo -e " Restarted $G payment $N "

End=$( date +%s )
Time=$(( $Start - $End ))

echo -e " Time Taken to setup ::: $G $Time $N "

