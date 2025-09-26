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
Remove_sh=$(basename "$0" | cut -d "." -f1)

Logfile="$shell_log/$Remove_sh.log"

echo " Script started at :: $(date) " | tee -a $Logfile

Status(){
    if [ $1 -ne 0 ]; then
        echo -e " $R Failed $N  $2  " | tee -a $Logfile
        exit 1
    else
        echo -e " $G Successfully $N $2 " | tee -a $Logfile
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
Status $? "Created repo"

dnf install mongodb-org -y &>>$Logfile
Status $? "Installed mongodb"

systemctl enable mongod &>>$Logfile
Status $? "Enabled service"

systemctl start mongod &>>$Logfile
Status $? "Started mongod"

# Fix sed command syntax
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
Status $? "Allowing remote connections"

systemctl restart mongod &>>$Logfile
Status $? "Mongod restarted and ready"
