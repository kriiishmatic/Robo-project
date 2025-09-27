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
Start=$(date +%s)

echo " Script started at :: $(date) " | tee -a $Logfile


Status(){
    if [ $1 -ne 0 ]; then
    echo -e " $R Failed $N  $2  " | tee -a $Logfile
    exit 1
else
    echo -e "$G Sucessfully $N $2 " | tee -a $Logfile
fi
}
dnf module disable redis -y &>>$Logfile
Status $? " Disabling redis "
dnf module enable redis:7 -y &>>$Logfile
Status $? " enabling redis "
dnf install redis -y &>>$Logfile
Status $? " installing redis "
sed -i -e 's/127\.0\.0\.1/0.0.0.0/' -e 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf
Status $? " changed allowed traffic"

systemctl enable redis &>>$Logfile
Status $? " enabling redis "
systemctl start redis &>>$Logfile
Status $? " starting redis "

End=$(date +%s)
Time=$(( $Start - $End ))

echo  -e " TIME TAKEN TO FINISH INSTALATION ::: $G $Time $N "