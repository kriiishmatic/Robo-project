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

########Frontend Nginx########
dnf module disable nginx -y &>>$Logfile
Status $? " Disabling nginx "
dnf module enable nginx:1.24 -y &>>$Logfile
Status $? " enabling nginx MODULE "
dnf install nginx -y &>>$Logfile
Status $? " Installing nginx "

systemctl enable nginx &>>$Logfile
Status $? " Enabling nginx "
systemctl start nginx &>>$Logfile
Status $? " Starting nginx "

rm -rf /usr/share/nginx/html/* &>>$Logfile
Status $? "Removing default html "

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 

unzip /tmp/frontend.zip &>>$Logfile

cp $DIR/nginx.conf /etc/nginx/nginx.conf &>>$Logfile
Status $? " Changing .conf file "
systemctl restart nginx &>>$Logfile
Status $? " Restarting for changes to apply in nginx "

End=$( date +%s )
Time=$(( $Start - $End ))

echo -e " Time Taken to setup ::: $G $Time $N "