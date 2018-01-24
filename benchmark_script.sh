#!/bin/bash

#pattern matching; Match maps containing this pattern only
pattern="Foo Bar"

#seconds of execution; How long should the map be run
#seconds=1666
#ticks=$(($seconds * 60))
ticks=100000


#runs; number of times each map should be ran for the duration specified
runs=3



#internal variables
filename="test_results"
OLDIFS=$IFS
IFS=$'\n'

#main loop
if [ -n "$(ls ../../saves | grep "$pattern")" ]; then
    echo "map_name,run_index,startup_time,end_time,avg_ms,min_ms,max_ms,ticks,execution_time,effective_UPS" >> $filename.csv
    else
    echo "No maps were found with the specified pattern \"$pattern\""
fi
for ((j=0; j<runs; j++))
    do
    for map in $(ls ../../saves | grep "$pattern")
        do
            ./factorio --benchmark "$map" --benchmark-ticks "$ticks" --disable-audio > temp
            avg_ms=$(cat temp | grep "avg:" | awk '{print $2}')
            min_ms=$(cat temp | grep "min:" | awk '{print $5}')
            max_ms=$(cat temp | grep "max:" | awk '{print $8}')
            execution_time=$(cat temp | grep "Performed" | awk '{print $5}')
            rm temp
            cp ../../factorio-current.log .
            startup_time=$(grep "Loading script.dat" factorio-current.log | awk '{print $1}')
            end_time=$(grep "Goodbye" factorio-current.log | awk '{print $1}')
            run_index=$(echo $j+1 | bc)
            UPS=$(echo "scale=4; $ticks/$execution_time*1000" | bc)
            #time_delta_avgms=$(echo "scale=3; 1000*($end_time-$startup_time)/$ticks" | bc)
            echo $map,$run_index,$startup_time,$end_time,$avg_ms,$min_ms,$max_ms,$ticks,$execution_time,$UPS >> $filename.csv
        done
    done

IFS=$OLDIFS

rm ./factorio-current.log
