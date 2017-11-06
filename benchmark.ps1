#run every map in the saves directory?
[bool]$allmaps = 0

if ($allmaps)
	{
	[string[]]$maps = dir ..\..\saves -n
	}
	else
	{
	[string[]]$maps = "35 40"
	$maps = $maps -split " "
}
#Number of seconds of simulation (higher = less error)
$seconds = 150
#Number of runs per map
$runs = 5

#End of user variables

#Put the name of every map in the result file
$maps -join "," >> test_results.csv
#Cut function because muh linux
function cut {
  param(
    [Parameter(ValueFromPipeline=$True)] [string]$inputobject,
    [string]$delimiter='\s+',
    [string[]]$field
  )
  process {
    if ($field -eq $null) { $inputobject -split $delimiter } else {
      ($inputobject -split $delimiter)[$field] }
  }
}

#run index
$i = 0
#map index
$k = 0

$ticks = $seconds * 60
while ($i -lt $runs){
	
	for ($k = 0; $k -lt $maps.length; $k++)
	{
		#Load the factorio executable with the settings above in benchmark mode
		#Piping to out-null ensures that the process completes before the next command is executed
		.\factorio.exe --benchmark $maps[$k] --benchmark-ticks $ticks --disable-audio | out-null
		
		#Make a copy of the log in our current directory, keep the original intact
		copy ..\..\factorio-current.log .
		
		#select the first field from the last two lines (the time of the last two events)
		$array = cat .\factorio-current.log | cut -f 1 | Select-Object -last 2
		
		#Fill the index of the current map with the calculated milliseconds
		[string[]]$ms += [math]::Round(($array[1] - $array[0]) / ($ticks / 1000),3)
	}
	#Record the milliseconds from all maps this run
	$ms -join"," >> test_results.csv
	
	#clear the variable before the next pass
	clear-variable ms
	$i++;
	echo "run# $i finished"

}
