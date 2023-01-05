#This script exports messages that have run longer than 1 hour to exportPath.
$exportPath = 'C:\ESB\Tools\ActiveMessageCount.json'
$timePrevHour = (Get-Date).AddHours(-1)

$mgmtDbServer = Get-WmiObject MSBTS_GroupSetting -Namespace root/MicrosoftBizTalkServer | Select-Object -Expand MgmtDbServerName
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.Operations")
$mgmtDbName = Get-WmiObject MSBTS_GroupSetting -Namespace root/MicrosoftBizTalkServer | Select-Object -Expand MgmtDbName
$getBodyOperation = New-Object Microsoft.BizTalk.Operations.BizTalkOperations($mgmtDbServer, $mgmtDbName)

$activeMessages = $getBodyOperation.GetMessages() | Where-Object ServiceType -gt "" | Where-Object InstanceStatus -Like "Active"
$actMsgOverHour = $activeMessages | Where-Object CreationTime -LT $timePrevHour
$serviceTypes = $actMsgOverHour | Select-Object ServiceType | Sort-Object ServiceType | Get-Unique -AsString


$instanceCount = ForEach ($serviceType in $serviceTypes.ServiceType) {
    $activeCount = ($actMsgOverHour | Where-Object ServiceType -Like $serviceType).Count
    $properties = [ordered] @{
    ServiceType = $ServiceType.Split(",")[0]; 
    Active = $activeCount
    }
    New-Object -TypeName PSObject -Property $properties
}


$instanceCount | ConvertTo-Json | Out-File $exportPath -Encoding ascii -Force