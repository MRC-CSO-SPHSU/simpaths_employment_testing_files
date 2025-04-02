#! /usr/bin/bash

end=$(expr $2 + 9)

mvn clean package

java -jar singlerun.jar -c UK -s $2 -Setup -g false --rewrite-policy-schedule

java -jar multirun.jar -s $2 -e $end -n 1 -p 30000 -r $1 -g false -f

cp output/2025*_$1*/csv/Person.csv outfiles/run_$1.csv
