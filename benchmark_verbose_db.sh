#!/bin/bash

trap "exit" SIGINT

#To be used in conjunction with a sqlite3 database. See Factorio-benchmarking-tools repo for SQL to create such a database.
#pattern matching; Match maps containing this pattern only
pattern=""
map_pool="$(ls -p ../../saves | grep -v / | grep "$pattern")"
note=""

ticks=260

#runs; number of times each map should be ran for the duration specified
runs=100
filename=verbose_test_results.csv

temp=$(mktemp)
IFS=$'\n'

if [ -n "$map_pool" ]; then
    echo "Checking for possible errors"
    for map in $map_pool
    do
        possible_error=$(./factorio --benchmark "$map" --benchmark-ticks 1 --benchmark-verbose wholeUpdate | grep "Error")
        if [ -n "$possible_error" ]; then
            echo "An error was detected, the map \"$map\" had an error:"
            echo "$possible_error"
            exit 1
        fi
    done
else
    echo "No maps were found with the specified pattern \"$pattern\""
    exit 0
fi

echo "Running verbose benchmark"

factorio_version=$(./factorio --version | head -n1 | awk '{ print $2 }')
executable_platform=$(./factorio --version | head -n1 | awk -F ' |,' '{ print $6 }' | tr -d ")")
executable_type=$(./factorio --version | head -n1 | awk -F ' |,' '{ print $NF }' | tr -d ")")
number_of_mods_installed=$(cat ../../mods/mod-list.json | grep "\"enabled\": true" | wc -l)
kernel_version=$(uname -r)


pre_collection_id=$(sqlite3 test.db "select max(collection_id) from benchmark_collection;")
sqlite3 test.db "INSERT INTO benchmark_collection(pattern, factorio_version, ticks, platform, executable_type, number_of_mods_installed, kernel_version, notes) VALUES (\"$pattern\", \"$factorio_version\", \"$ticks\", \"$executable_platform\", \"$executable_type\", \"$number_of_mods_installed\", \"$kernel_version\", \"$note\");"
collection_id=$(sqlite3 test.db "select max(collection_id) from benchmark_collection;")
if [[ $pre_collection_id = $collection_id ]] ; then
    echo "Failed to create a collection_id"
    exit 1
fi

startTime=$(date +%s)

for map in $map_pool
do
    ./factorio --benchmark "$map" --benchmark-ticks "$ticks" --benchmark-runs $runs --benchmark-verbose tick,wholeUpdate,gameUpdate,circuitNetworkUpdate,transportLinesUpdate,fluidsUpdate,entityUpdate,mapGenerator,electricNetworkUpdate,logisticManagerUpdate,constructionManagerUpdate,pathFinder,trains,trainPathFinder,commander,chartRefresh,luaGarbageIncremental,chartUpdate,scriptUpdate > $temp
    map_hash=$(sha1sum ../../saves/"$map" | awk '{print $1}')
    map_version=$(grep "Info Scenario.cpp.*Map version" $temp | awk -F' |-' '{print $(NF-1)}' | head -n1)
    sqlite3 test.db "INSERT INTO benchmark_base(map_name, map_hash, saved_map_version, number_of_runs, ticks, collection_id) VALUES (\"$map\", \"$map_hash\", \"$map_version\", \"$runs\", \"$ticks\", \"$collection_id\");"
    map_current_id=$(sqlite3 test.db "select max(benchmark_id) from benchmark_base where map_hash = \"$map_hash\";")
    current_run_index=0
    temp2=$(mktemp)
    echo "run_index,tick_number,wholeUpdate,gameUpdate,circuitNetworkUpdate,transportLinesUpdate,fluidsUpdate,entityUpdate,mapGenerator,electricNetworkUpdate,logisticManagerUpdate,constructionManagerUpdate,pathFinder,trains,trainPathFinder,commander,chartRefresh,luaGarbageIncremental,chartUpdate,scriptUpdate,benchmark_id" >> $temp2
    for line in $(grep 't[0-9]*[0-9],[0-9]*,[0-9]*' $temp); do
        if [[ -n $(echo $line | grep "t0,") ]]; then
            let current_run_index++
        fi
        #strip the t off the tick_number and remove trailing comma
        line2=$(echo $line | tr -d 't' | sed 's/,$//')
        echo $current_run_index,$line2,$map_current_id >> $temp2
    done
    cat $temp > temp1
    cat $temp2 > temp2
    rm $temp
    sqlite3 -cmd ".mode csv" test.db ".import $temp2 temp_table"
    sqlite3 test.db "insert into benchmark_verbose (run_index,tick_number,wholeUpdate,gameUpdate,circuitNetworkUpdate,transportLinesUpdate,fluidsUpdate,entityUpdate,mapGenerator,electricNetworkUpdate,logisticManagerUpdate,constructionManagerUpdate,pathFinder,trains,trainPathFinder,commander,chartRefresh,luaGarbageIncremental,chartUpdate,scriptUpdate,benchmark_id) select * from temp_table; DROP TABLE temp_table;"
    rm $temp2
done
