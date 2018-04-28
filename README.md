# factorio_benchmark_scripts

A collection of scripts to streamline benchmarking Factorio. WARNING: the Windows PowerShell script logs signifigantly less data, and is not maintained to the same level as the Linux script. Use of the Linux script is advised.

<b>How to use:</b>
1. Download the standalone version of Factorio
2. Download the appropriate version of the script (Windows/Linux)
3. Place the script in the bin directory alongside the Factorio executable
4. Place the maps you want to benchmark in the saves directory
4a. Modify the script to match the patten you specify
5. Run the script
6. The file test_results.csv will be output into the bin directory containing the time in ms for execution per map.

<b>Caveats:</b>

The method of obtaining the execution time of the benchmark is extrapolated from the log file because output redirection is broken on Windows. There is a workaround but I'm lazy. As a result the reported times will be trivially higher than the number Factorio spits out with this technique. As long as results between the two techniques are not compared (ie only between like methods) it should provide an accurate comparison. This means the average ms reported on Windows with this script will not be the same as the one the Factorio executable spits out.
