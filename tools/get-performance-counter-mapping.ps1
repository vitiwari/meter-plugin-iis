Function Get-PerformanceCounterLocalName
{
  param
  (
    [UInt32]
    $ID,
 
    $ComputerName = $env:COMPUTERNAME
  )
 
  $code = '[DllImport("pdh.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern UInt32 PdhLookupPerfNameByIndex(string szMachineName, uint dwNameIndex, System.Text.StringBuilder szNameBuffer, ref uint pcchNameBufferSize);'
 
  $Buffer = New-Object System.Text.StringBuilder(1024)
  [UInt32]$BufferSize = $Buffer.Capacity
 
  $t = Add-Type -MemberDefinition $code -PassThru -Name PerfCounter -Namespace Utility
  $rv = $t::PdhLookupPerfNameByIndex($ComputerName, $id, $Buffer, [Ref]$BufferSize)
 
  if ($rv -eq 0)
  {
    $Buffer.ToString().Substring(0, $BufferSize-1)
  }
  else
  {
    Throw 'Get-PerformanceCounterLocalName : Unable to retrieve localized name. Check computer name and performance counter ID.'
  }
}

function Get-PerformanceCounterIDHash
{
    if ($script:perfHash -eq $null)
    {
        Write-Progress -Activity 'Retrieving PerfIDs' -Status 'Working'
 
        $key = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\CurrentLanguage'
        $counters = (Get-ItemProperty -Path $key -Name Counter).Counter
        $script:perfHash = @{}
        $all = $counters.Count
 
        for($i = 0; $i -lt $all; $i+=2)
        {
           Write-Progress -Activity 'Retrieving PerfIDs' -Status 'Working' -PercentComplete ($i*100/$all)
           $script:perfHash.$($counters[$i+1]) = $counters[$i]
        }
    }
 
    #$script:perfHash.$Name
    $script:perfHash
}

function Get-PerformanceCounterIDString
{
    param
    (
        [Parameter(Mandatory=$true)]
        [string[]]$List
    )

    $perfhash = Get-PerformanceCounterIDHash
    foreach ($counter in $List)
    {
        
        $matches = [regex]::Matches($counter, "\\([.a-zA-Z ]+)(\(.*\))?\\(.*)")
        
        $left = $matches.Groups[1].Value
        $right = $matches.Groups[3].Value
        $middle = $matches.Groups[2].Value

        #$idSet = $perfHash.$left
        #$idCounter = $perfHash.$right
        
        $idLeft = $perfHash.$left
        $idRight = $perfhash.$right

        # Write-Host $idCounter
        $result = $counter
                
        $leftLocalname = Get-PerformanceCounterLocalName $idLeft
        $rightLocalname = Get-PerformanceCounterLocalName $idRight
        Write-Host "$counter : \$leftLocalname$middle\$rightLocalname"
    }
            
    #$perfhash | Get-Member
}
 
#$counters = "\Processor(_Total)\% Processor Time","\System\Processor Queue Length","\Memory\Available Bytes","\Memory\Pages/sec","\PhysicalDisk(_Total)\% Disk Time","\PhysicalDisk(_Total)\% Disk Time","\ASP.NET Applications(__Total__)\Requests/Sec","\ASP.NET\Application Restarts","\ASP.NET\Request Wait Time","\ASP.NET\Requests Queued","\.NET CLR Exceptions(_Global_)\# of Exceps Thrown / sec","\.NET CLR Memory(_Global_)\# Total committed Bytes","\Web Service(_Total)\Get Requests/sec","\Web Service(_Total)\Post Requests/sec","\Web Service(_Total)\Current Connections"
$counters = $args
Get-PerformanceCounterIDString $counters