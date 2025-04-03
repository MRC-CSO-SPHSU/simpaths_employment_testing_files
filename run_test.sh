#! /usr/bin/bash

hash=$(git rev-parse HEAD)

rm input/input* || echo "Clean input directory!\n"

start=$(ls input/InitialPopulations/training | grep -o '[0-9]*')


end=$(expr  $start + 9)

mvn clean package

java -jar singlerun.jar -c UK -s $start -Setup -g false --rewrite-policy-schedule ||
  java -jar singlerun.jar -c UK -s $start -Setup -g false

java -jar multirun.jar -s $start -e $end -n 1 -p 30000 -r 999 -g false

cp output/2025*/csv/Person.csv outfiles/run_${hash:0:10}.csv &&
    rm -r output/2025*

./calculate_stats.R ${hash:0:10}
