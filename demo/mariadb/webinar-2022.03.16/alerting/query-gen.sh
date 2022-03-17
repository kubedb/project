#!/bin/bash

while :
do
    mysql -ualif -h127.0.0.1 -p1234 -e 'select 1;' > /dev/null
    mysql -ualif -h127.0.0.1 -p1234 -e "INSERT INTO playground.equipment (type, quant, color) VALUES ('slide', 2, 'blue');" > /dev/null
    mysql -ualif -h127.0.0.1 -p1234 -e "select count(id) from playground.equipment;" 
    sleep 0.0001
done
