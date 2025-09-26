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

dnf install maven -y

id roboshop &>>$Logfile
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    else
    echo -e " Already installed $Y SKIPPED! $N "
fi


mkdir -p /app 
Status $? "Creating directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
Status $? "Dowloading code zip"


cd /app 
rm -rf /app/*
Status $? "Removed previous code"

unzip /tmp/shipping.zip &>>$Logfile
Status $? "unzipping latest code"

cd /app 

mvn clean package  &>>$Logfile
Status $? "installed the DEPENDENCIES for Maven/java "
mv target/shipping-1.0.jar shipping.jar &>>$Logfile
Status $? "Moving jars geek!"

cp $DIR/shipping.service /etc/systemd/system/shipping.service
Status $? "Copied shipping service"

systemctl daemon-reload
Status $? "Demonic reload"

systemctl enable shipping &>>$Logfile
Status $? "Enabled the node"

systemctl start shipping &>>$Logfile
Status $? "Start it "

systemctl restart shipping &>>$Logfile
Status $? "Restarted the service"

echo -e " Restarted $G shipping $N "

End=$( date +%s )
Time=$(( $Start - $End ))

echo " Time Taken to setup ::: $G $Time $N "

