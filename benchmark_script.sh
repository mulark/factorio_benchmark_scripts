#!/bin/bash

trap "exit" SIGINT

#pattern matching; Match maps containing this pattern only
pattern="test-000017"

#seconds of execution; How long should the map be run
#seconds=1666
#ticks=$(($seconds * 60))
ticks=20000


#runs; number of times each map should be ran for the duration specified
runs=3

#could be standalone, TODO fix it
platform="LinuxHeadless"
executable_name="factorio"

#internal variables
filename="test_results"
OLDIFS=$IFS
IFS=$'\n'

#main loop
if [ -n "$(ls ../../saves | grep "$pattern")" ]; then
    echo $(ls ../../saves | grep "$pattern")
    echo "map_name,run_index,startup_time,end_time,avg_ms,min_ms,max_ms,ticks,execution_time,effective_UPS,factorio_version,executable_type" >> $filename.csv
    else
    echo "No maps were found with the specified pattern \"$pattern\""
    exit 0
fi
for ((j=0; j<runs; j++))
    do
    for map in $(ls -p ../../saves | grep -v / | grep "$pattern")
        do
            echo "$map","$executable_name"
            ./$executable_name --benchmark "$map" --benchmark-ticks "$ticks" | tee temp
            avg_ms=$(cat temp | grep "avg:" | awk '{print $2}')
            min_ms=$(cat temp | grep "min:" | awk '{print $5}')
            max_ms=$(cat temp | grep "max:" | awk '{print $8}')
            factorio_version=$(head temp -n 1 | awk '{print $5}')
            execution_time=$(cat temp | grep "Performed" | awk '{print $5}')
            #rm temp
            cp ../../factorio-current.log .
            startup_time=$(grep "Loading script.dat" factorio-current.log | awk '{print $1}')
            end_time=$(grep "Goodbye" factorio-current.log | awk '{print $1}')
            run_index=$(echo $j+1 | bc)
            UPS=$(echo "scale=4; $ticks/$execution_time*1000" | bc)
            echo $map,$run_index,$startup_time,$end_time,$avg_ms,$min_ms,$max_ms,$ticks,$execution_time,$UPS,$factorio_version,$platform >> $filename.csv
            rm ./factorio-current.log
        done
    done

IFS=$OLDIFS
