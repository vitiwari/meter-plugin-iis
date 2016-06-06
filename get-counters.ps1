# Define constants for program, PS way of doing this to make the real constants??
$CONFIG_FILE_NAME="counters.json"
$PARAM_FILE_NAME="param.json"
    
# Read configuration file which is encoded in JSON into PSObject
# How to handle if the JSON is not properly formed. What is returned, null?
$config = (Get-Content $CONFIG_FILE_NAME) -join "`n" | ConvertFrom-JSON
$param = (Get-Content $PARAM_FILE_NAME) -join "`n" | ConvertFrom-JSON

$hostname = Get-Content Env:\COMPUTERNAME

# Get the source from the parameter file if missing or empty use
# the name of the source
$source = $param.source
if ($source.Length -eq 0) {
    $source = $hostname
}
$delay = $param.delay

$counter_names = @()
$multipliers = @{}
$metric_ids = @{}

<#
1) Generate an array of the counter names we need to collect
2) Generate a map of the multiplier to counter name
3) Generate a map of the metric id to counter name
#>

foreach ($counter in $config.counters) {
  # add each of the counters into an array
  $counter_names += $counter.counter_name

  # Generate a key to lookup metric id and multiplier
  $counter_name = $counter.counter_name.ToString()

  $key = "\\$hostname$counter_name".ToUpper()

  # Add values to the lookup maps
  $multipliers[$key] = $counter.multiplier
  $metric_ids[$key] = $counter.metric_id
}

# Continuously loop collecting metrics from the Windows Performance Counters
while($true)
{
    $counters = Get-Counter -Counter $counter_names
    $samples = $counters.CounterSamples
    foreach ($s in $samples) {
        $value = $s.CookedValue * $multipliers[$s.path]
        $metric_id = $metric_ids[($s.path).toUpper()]
        Write-Host $metric_id $value $source
    }
    Start-Sleep -m $delay
}
