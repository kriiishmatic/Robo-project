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
dnf install mysql-server -y &>>$Logfile
Status $? "Installing MYSQL"
systemctl enable mysqld &>>$Logfile
Status $? "Enabling MYSQL"
systemctl start mysqld &>>$Logfile
Status $? "Starting MYSQL"
mysql_secure_installation --set-root-pass RoboShop@1 &>>$Logfile
Status $? "Setting password"

End=$(date +%s)
Time=(( $Start - $End ))

echo  -e " TIME TAKEN TO FINISH INSTALATION ::: $G $Time $N "