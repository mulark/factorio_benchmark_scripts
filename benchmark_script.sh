#!/bin/bash

#TODO actually implement maps by name
#Semi-obsolete by pattern matching
allmaps=true

#default off as it is a linux exclusive measurement
alternate_mode=false

#How long should each map be tested and how many times
seconds=150
runs=5

#Restrict the number of maps tested based on a pattern matching string
pattern=""

#Name of the output file
filename="test_results"

#Use seconds to calculate the ticks, alternatively specify ticks manually
ticks=$(($seconds * 60))

if ($allmaps) ; then
    if [ -z "$pattern" ] ; then
        #If no pattern is supplied don't attempt to pass the pattern to grep
        maps=($(ls -1 ../../saves))
        ls -1 ../../saves | paste -sd "," >> $filename.csv
        if ($alternate_mode) ; then ls -1 ../../saves | paste -sd "," >> $filename.alternate.csv ; fi
    else
        maps=($(ls -1 ../../saves | grep $pattern))
        ls -1 ../../saves | grep $pattern | paste -sd "," >> $filename.csv
        if ($alternate_mode) ; then ls -1 ../../saves | grep $pattern | paste -sd "," >> $filename.alternate.csv ; fi
    fi
fi

for ((j=0; j<runs; j++))
do
    for i in "${maps[@]}"
    do
        if ($alternate_mode) ; then
        ms=($(./factorio --benchmark "$i" --benchmark-ticks "$ticks" --disable-audio | grep avg | awk '{print $2}'))
        echo -n $ms, >> $filename.alternate.csv
        else
        ./factorio --benchmark "$i" --benchmark-ticks "$ticks" --disable-audio
        fi
        #roundabout way of gathering benchmark time not strictly necessary on linux
        #but to keep results more consistent between windows and linux it is used
        cp ../../factorio-current.log .
        ms=($(tail -n 2 factorio-current.log | awk '{print $1}' | paste -s | awk '{print $2 - $1}'))
        time=$(printf %.4f $(echo "$ms / $ticks * 1000" |bc -l))
        echo -n $time, >> $filename.csv
    done
    echo >> $filename.csv
    if ($alternate_mode) ; then echo >> $filename.alternate.csv ; fi
done
