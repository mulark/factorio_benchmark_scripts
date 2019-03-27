#!/bin/bash

trap "exit" SIGINT

#pattern matching; Match maps containing this pattern only
pattern="test-000017"

ticks=20000

#runs; number of times each map should be ran for the duration specified
runs=3
filename=verbose_test_results.csv

echo "Running verbose benchmark"
startTime=$(date +%s)
temp=$(mktemp)

#main loop
if [ -n "$(ls ../../saves | grep "$pattern")" ]; then
    echo $(ls ../../saves | grep "$pattern")
    echo "map_name,ticks,runIndex,avg_ms,execution_time,factorio_version,executable_type,wholeUpdateSum,gameUpdateSum,circuitNetworkUpdateSum,transportLinesUpdateSum,fluidsUpdateSum,entityUpdateSum,mapGeneratorSum,electricNetworkUpdateSum,logisticManagerUpdateSum,constructionManagerUpdateSum,trainsSum,trainPathFinderSum,commanderSum,chartRefreshSum,luaGarbageIncrementalSum,chartUpdateSum,scriptUpdateSum" >> $filename
    else
    echo "No maps were found with the specified pattern \"$pattern\""
    exit 0
fi

factorio_version=$(./factorio --version | head -n1 | awk '{ print $2 }')
executable_type=$(./factorio --version | head -n1 | awk -F ',' '{ print $2 $3 }' | tr -d ")")

for ((j=1; j<=runs; j++))
    do
    for map in $(ls -p ../../saves | grep -v / | grep "$pattern")
        do
            echo "$map"
            ./factorio --benchmark "$map" --benchmark-ticks "$ticks" --benchmark-verbose all > $temp
            cat $temp | grep 'tick\|t[0-9]' | tail -n$ticks > verbose_temp
            avg_ms=$(cat $temp | grep "avg:" | awk '{print $2}')
            runIndex=$j
            execution_time=$(cat $temp | grep "Performed" | awk '{print $5}')
            rm $temp
            timestamp=$(cat verbose_temp | awk -F ',' '{print $2}' | tail -n+2 | paste -s -d+ - | bc)
            wholeUpdateSum=$(cat verbose_temp | awk -F ',' '{print $3}' | tail -n+2 | paste -s -d+ - | bc)
            gameUpdateSum=$(cat verbose_temp | awk -F ',' '{print $5}' | tail -n+2 | paste -s -d+ - | bc)
            circuitNetworkUpdateSum=$(cat verbose_temp | awk -F ',' '{print $6}' | tail -n+2 | paste -s -d+ - | bc)
            transportLinesUpdateSum=$(cat verbose_temp | awk -F ',' '{print $7}' | tail -n+2 | paste -s -d+ - | bc)
            fluidsUpdateSum=$(cat verbose_temp | awk -F ',' '{print $8}' | tail -n+2 | paste -s -d+ - | bc)
            entityUpdateSum=$(cat verbose_temp | awk -F ',' '{print $9}' | tail -n+2 | paste -s -d+ - | bc)
            mapGeneratorSum=$(cat verbose_temp | awk -F ',' '{print $10}' | tail -n+2 | paste -s -d+ - | bc)
            electricNetworkUpdateSum=$(cat verbose_temp | awk -F ',' '{print $21}' | tail -n+2 | paste -s -d+ - | bc)
            logisticManagerUpdateSum=$(cat verbose_temp | awk -F ',' '{print $22}' | tail -n+2 | paste -s -d+ - | bc)
            constructionManagerUpdateSum=$(cat verbose_temp | awk -F ',' '{print $23}' | tail -n+2 | paste -s -d+ - | bc)
            trainsSum=$(cat verbose_temp | awk -F ',' '{print $25}' | tail -n+2 | paste -s -d+ - | bc)
            trainPathFinderSum=$(cat verbose_temp | awk -F ',' '{print $26}' | tail -n+2 | paste -s -d+ - | bc)
            commanderSum=$(cat verbose_temp | awk -F ',' '{print $27}' | tail -n+2 | paste -s -d+ - | bc)
            chartRefreshSum=$(cat verbose_temp | awk -F ',' '{print $28}' | tail -n+2 | paste -s -d+ - | bc)
            luaGarbageIncrementalSum=$(cat verbose_temp | awk -F ',' '{print $29}' | tail -n+2 | paste -s -d+ - | bc)
            chartUpdateSum=$(cat verbose_temp | awk -F ',' '{print $30}' | tail -n+2 | paste -s -d+ - | bc)
            scriptUpdateSum=$(cat verbose_temp | awk -F ',' '{print $31}' | tail -n+2 | paste -s -d+ - | bc)
            rm ./verbose_temp
            echo "$map,$ticks,$runIndex,$avg_ms,$execution_time,$factorio_version,$executable_type,$wholeUpdateSum,$gameUpdateSum,$circuitNetworkUpdateSum,$transportLinesUpdateSum,$fluidsUpdateSum,$entityUpdateSum,$mapGeneratorSum,$electricNetworkUpdateSum,$logisticManagerUpdateSum,$constructionManagerUpdateSum,$trainsSum,$trainPathFinderSum,$commanderSum,$chartRefreshSum,$luaGarbageIncrementalSum,$chartUpdateSum,$scriptUpdateSum" >> $filename
            if [ -n "$timeOfFinishEstimate" ]; then
                echo "t$(echo "$(date +%s)-$timeOfFinishEstimate" | bc)"
            fi

        done
        if [ -z "$run1_End" ]; then
            run1_End=$(date +%s)
            elasped=$(echo "$run1_End - $startTime" | bc)
            if (( $runs > 1 )); then
                timeOfFinishEstimate=$(echo "$elasped * ($runs - 1) + $run1_End" | bc)
                echo $timeOfFinishEstimate
            fi
        fi

    done
