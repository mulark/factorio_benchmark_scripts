#!/bin/bash

#pattern matching; Match maps containing this pattern only
pattern="Foo Bar"

#seconds of execution; How long should the map be run
seconds=30

#runs; number of times each map should be ran for the duration specified
runs=1



#internal variables
ticks=$(($seconds * 60))
filename="test_results"
OLDIFS=$IFS
IFS=$'\n'

#main loop
echo "map_name,run_index,startup_time,end_time,avg_ms,ticks,UPS" >> $filename.csv
for ((j=0; j<runs; j++))
    do
    for map in $(ls ../../saves | grep "$pattern")
        do
            avg_ms=$(./factorio --benchmark "$map" --benchmark-ticks "$ticks" --disable-audio | grep "avg" | awk '{print $2}')
            cp ../../factorio-current.log .
            startup_time=$(grep "Loading script.dat" factorio-current.log | awk '{print $1}')
            end_time=$(grep "Goodbye" factorio-current.log | awk '{print $1}')
            run_index=$(echo $j+1 | bc)
            UPS=$(echo "scale=2; 1000/$avg_ms" | bc)
            #time_delta_avgms=$(echo "scale=3; 1000*($end_time-$startup_time)/$ticks" | bc)
            echo $map,$run_index,$startup_time,$end_time,$avg_ms,$ticks,$UPS >> $filename.csv
        done
    done

IFS=$OLDIFS
