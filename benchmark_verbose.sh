#!/bin/bash

trap "exit" SIGINT

#pattern matching; Match maps containing this pattern only
pattern="test-000035"
map_pool="$(ls -p ../../saves | grep -v / | grep "$pattern")"
ticks=10000

#runs; number of times each map should be ran for the duration specified
runs=3
filename=verbose_test_results.csv

startTime=$(date +%s)
temp=$(mktemp)
IFS=$'\n'

if [ -n "$map_pool" ]; then
    echo "Checking for possible errors"
    for map in $map_pool
    do
        possible_error=$(./factorio --benchmark "$map" --benchmark-ticks 1 --benchmark-verbose all | grep "Error")
        if [ -n "$possible_error" ]; then
            echo "An error was detected, the map \"$map\" had an error:"
            echo "$possible_error"
            exit 1
        fi
    done
    echo $map_pool
    echo "map_name,ticks,run_index,avg_ms,execution_time,factorio_version,executable_type,wholeUpdateSum,gameUpdateSum,circuitNetworkUpdateSum,transportLinesUpdateSum,fluidsUpdateSum,entityUpdateSum,mapGeneratorSum,electricNetworkUpdateSum,logisticManagerUpdateSum,constructionManagerUpdateSum,trainsSum,trainPathFinderSum,commanderSum,chartRefreshSum,luaGarbageIncrementalSum,chartUpdateSum,scriptUpdateSum" >> $filename
else
    echo "No maps were found with the specified pattern \"$pattern\""
    exit 0
fi

echo "Running verbose benchmark"

factorio_version=$(./factorio --version | head -n1 | awk '{ print $2 }')
executable_type=$(./factorio --version | head -n1 | awk -F ',' '{ print $2 $3 }' | tr -d ")")

for ((j=1; j<=runs; j++))
    do
    for map in $map_pool
        do
            ./factorio --benchmark "$map" --benchmark-ticks "$ticks" --benchmark-verbose all > $temp
            map_version=$(grep "Info Scenario.cpp.*Map version" $temp | awk -F' |-' '{print $(NF-1)}')
            grep 'tick\|t[0-9]' $temp | tail -n$ticks > verbose_temp
            avg_ms=$(grep "avg:" $temp | awk '{print $2}')
            run_index=$j
            execution_time=$(cat $temp | grep "Performed" | awk '{print $5}')
            rm $temp
            timestamp=$(cat verbose_temp | awk -F ',' '{print $2}' | tail -n+1 | paste -s -d+ - | bc)
            wholeUpdateSum=$(cat verbose_temp | awk -F ',' '{print $3}' | tail -n+1 | paste -s -d+ - | bc)
            gameUpdateSum=$(cat verbose_temp | awk -F ',' '{print $5}' | tail -n+1 | paste -s -d+ - | bc)
            circuitNetworkUpdateSum=$(cat verbose_temp | awk -F ',' '{print $6}' | tail -n+1 | paste -s -d+ - | bc)
            transportLinesUpdateSum=$(cat verbose_temp | awk -F ',' '{print $7}' | tail -n+1 | paste -s -d+ - | bc)
            fluidsUpdateSum=$(cat verbose_temp | awk -F ',' '{print $8}' | tail -n+1 | paste -s -d+ - | bc)
            entityUpdateSum=$(cat verbose_temp | awk -F ',' '{print $9}' | tail -n+1 | paste -s -d+ - | bc)
            mapGeneratorSum=$(cat verbose_temp | awk -F ',' '{print $10}' | tail -n+1 | paste -s -d+ - | bc)
            electricNetworkUpdateSum=$(cat verbose_temp | awk -F ',' '{print $21}' | tail -n+1 | paste -s -d+ - | bc)
            logisticManagerUpdateSum=$(cat verbose_temp | awk -F ',' '{print $22}' | tail -n+1 | paste -s -d+ - | bc)
            constructionManagerUpdateSum=$(cat verbose_temp | awk -F ',' '{print $23}' | tail -n+1 | paste -s -d+ - | bc)
            trainsSum=$(cat verbose_temp | awk -F ',' '{print $25}' | tail -n+1 | paste -s -d+ - | bc)
            trainPathFinderSum=$(cat verbose_temp | awk -F ',' '{print $26}' | tail -n+1 | paste -s -d+ - | bc)
            commanderSum=$(cat verbose_temp | awk -F ',' '{print $27}' | tail -n+1 | paste -s -d+ - | bc)
            chartRefreshSum=$(cat verbose_temp | awk -F ',' '{print $28}' | tail -n+1 | paste -s -d+ - | bc)
            luaGarbageIncrementalSum=$(cat verbose_temp | awk -F ',' '{print $29}' | tail -n+1 | paste -s -d+ - | bc)
            chartUpdateSum=$(cat verbose_temp | awk -F ',' '{print $30}' | tail -n+1 | paste -s -d+ - | bc)
            scriptUpdateSum=$(cat verbose_temp | awk -F ',' '{print $31}' | tail -n+1 | paste -s -d+ - | bc)
            rm ./verbose_temp
            echo "$map,$ticks,$run_index,$avg_ms,$execution_time,$factorio_version,$executable_type,$wholeUpdateSum,$gameUpdateSum,$circuitNetworkUpdateSum,$transportLinesUpdateSum,$fluidsUpdateSum,$entityUpdateSum,$mapGeneratorSum,$electricNetworkUpdateSum,$logisticManagerUpdateSum,$constructionManagerUpdateSum,$trainsSum,$trainPathFinderSum,$commanderSum,$chartRefreshSum,$luaGarbageIncrementalSum,$chartUpdateSum,$scriptUpdateSum" >> $filename
            if [ -n "$timeOfFinishEstimate" ]; then
                echo "t$(echo "$(date +%s)-$timeOfFinishEstimate" | bc)"
            fi

        done
        if [ -z "$run1_End" ]; then
            run1_End=$(date +%s)
            elasped=$(echo "$run1_End - $startTime" | bc)
            if (( $runs > 1 )); then
                timeOfFinishEstimate=$(echo "$elasped * ($runs - 1) + $run1_End" | bc)
                echo "t$(echo "$(date +%s)-$timeOfFinishEstimate" | bc)"
            fi
        fi

    done
