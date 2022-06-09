COUNTER=0

USER='test'
PROXYSQL_NAME='proxy-mysql-server'
NAMESPACE='demo'
PASS='test'

VAR="x"

while [  $COUNTER -lt 100 ]; do
    let COUNTER=COUNTER+1
    VAR=a$VAR
    mysql -u$USER -h$PROXYSQL_NAME.$NAMESPACE.svc -P6033 -p$PASS -e 'select 1;' > /dev/null 2>&1
    mysql -u$USER -h$PROXYSQL_NAME.$NAMESPACE.svc -P6033 -p$PASS -e "INSERT INTO random.randomtb(colma, colmb) VALUES ('$VAR',50);" > /dev/null 2>&1
    mysql -u$USER -h$PROXYSQL_NAME.$NAMESPACE.svc -P6033 -p$PASS -e "select * from random.randomtb;" > /dev/null 2>&1
    sleep 0.0001
done
