# Don't know why but when it runs from a shel the language is US, instead of non-us for non-us Windows versions.

$counters = $args

#$counters = "\Processor(_Total)\% Processor Time","\System\Processor Queue Length","\Memory\Available Bytes","\Memory\Pages/sec","\PhysicalDisk(_Total)\% Disk Time","\PhysicalDisk(_Total)\% Disk Time","\ASP.NET Applications(__Total__)\Requests/Sec","\ASP.NET\Application Restarts","\ASP.NET\Request Wait Time","\ASP.NET\Requests Queued","\.NET CLR Exceptions(_Global_)\# of Exceps Thrown / sec","\.NET CLR Memory(_Global_)\# Total committed Bytes","\Web Service(_Total)\Get Requests/sec","\Web Service(_Total)\Post Requests/sec","\Web Service(_Total)\Current Connections"

#$counters = "\Processor(_Total)\% Processor Time"
#$counters = "\Processador(_Total)\% Tempo de Processador"

(Get-Counter -Counter $counters).CounterSamples | ForEach-Object {Join-String -Strings $_.Path,$_.CookedValue -Separator ' : '}

#Write-Output "\Processor(_Total)\% Processor Time : 123.45"
#Write-Output "\System\Processor Queue Length : 123.45"
#Write-Output "\Memory\Available Bytes : 123.45"
#Write-Output "\Memory\Pages/sec : 123.45"
#Write-Output "\PhysicalDisk(_Total)\% Disk Time : 123.45"
#Write-Output "\ASP.NET Applications(__Total__)\Requests/Sec : 123.45"
#Write-Output "\ASP.NET\Application Restarts : 123.45"
#Write-Output "\ASP.NET\Request Wait Time : 123.45"
#Write-Output "\ASP.NET\Requests Queued : 123.45"
#Write-Output "\.NET CLR Exceptions(_Global_)\# of Exceps Thrown / sec : 123.45"
#Write-Output "\.NET CLR Memory(_Global_)\# Total committed Bytes : 123.45"
#Write-Output "\Web Service(_Total)\Get Requests/sec : 123.45"
#Write-Output "\Web Service(_Total)\Post Requests/sec : 123.45"
#Write-Output "\Web Service(_Total)\Current Connections : 123.45"