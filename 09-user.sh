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

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
Status $? "Dowloading code zip"


cd /app 
rm -rf /app/*
Status $? "Removed previous code"

unzip /tmp/user.zip &>>$Logfile
Status $? "unzipping latest code"

cd /app 

npm install &>>$Logfile
Status $? "installed the DEPENDENCIES"

cp $DIR/user.service /etc/systemd/system/user.service
Status $? "Copied user service"

systemctl daemon-reload
Status $? "Demonic reload"

systemctl enable user &>>$Logfile
Status $? "Enabled the node"

systemctl start user &>>$Logfile
Status $? "Start it "

systemctl restart user &>>$Logfile
Status $? "Restarted the service"

echo -e " Restarted $G user $N "

End=$( date +%s )
Time=$(( $Start - $End ))

echo " Time Taken to setup ::: $G $Time $N "

