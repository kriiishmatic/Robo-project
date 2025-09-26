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
DIR=$PWD
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

cp $DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$Logfile
Status $? "Created rabbit.rep "
dnf install rabbitmq-server -y &>>$Logfile
Status $? "installing RabbitMQ "
systemctl enable rabbitmq-server &>>$Logfile
Status $? "Enabling RabbitMQ "
systemctl start rabbitmq-server &>>$Logfile
Status $? "Started RabbitMQ "
echo " $G Successfully installed and enabled RabbitMQ $N " &>>$Logfile
rabbitmqctl add_user roboshop roboshop123 &>>$Logfile
Status $? "Added System user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$Logfile
Status $? "Given Root permissions "

End=$(date +%s)
Time=$(( $Start - $End ))

echo  -e " TIME TAKEN TO FINISH INSTALATION ::: $G $Time $N "