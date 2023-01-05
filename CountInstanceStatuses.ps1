#This script counts the numer of messages with all instance statuses per ServiceType.

$i = 0

DO{
$i++
$mgmtDbServer = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.Operations")
$mgmtDbName = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
$getBodyOperation = New-Object Microsoft.BizTalk.Operations.BizTalkOperations($mgmtDbServer, $mgmtDbName)

$messages = $getBodyOperation.GetMessages() | Where-Object ServiceType -gt ""
$ServiceTypes = $messages | Select-Object ServiceType | Sort-Object ServiceType | Get-Unique -AsString

$InstanceStatuses = "Active","Suspended","Dehydrated","SuspendedNotResumable","Running"


$instanceCount = ForEach ($ServiceType in $ServiceTypes.ServiceType) {
    $ActiveCount = ($messages | Where-Object InstanceStatus -Like "Active" | Where-Object ServiceType -like "$ServiceType").count
    $SuspendedCount = ($messages | Where-Object InstanceStatus -Like "Suspended" | Where-Object ServiceType -like "$ServiceType").count
    $DehydratedCount = ($messages | Where-Object InstanceStatus -Like "Dehydrated" | Where-Object ServiceType -like "$ServiceType").count
    $SuspendedNotResumableCount = ($messages | Where-Object InstanceStatus -Like "SuspendedNotResumable" | Where-Object ServiceType -like "$ServiceType").count
    $RunningCount = ($messages | Where-Object InstanceStatus -Like "Running" | Where-Object ServiceType -like "$ServiceType").count

$Properties = [ordered]@{'ServiceType' = $ServiceType.Split(",")[0]; 'Active' = $ActiveCount; 'Suspended' = $SuspendedCount; 'Dehydrated' = $DehydratedCount; 'SuspendedNotResumable' = $SuspendedNotResumableCount; 'Running' = $RunningCount}
New-Object -TypeName PSObject -Property $Properties
}

#Writes summary to json-file
$instanceCount | ConvertTo-Json | Out-File "C:\ESB\Tools\InstanceCountPerService.json" -Encoding ascii -Force

start-sleep -seconds 28
}

While ($i -lt 10)
