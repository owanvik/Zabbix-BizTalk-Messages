#This script counts the number of suspended messages for each ServiceType in BizTalk.
$mgmtDbServer = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.Operations")
$mgmtDbName = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
$getBodyOperation = New-Object Microsoft.BizTalk.Operations.BizTalkOperations($mgmtDbServer, $mgmtDbName)

$messages = $getBodyOperation.GetMessages() | Where-Object ServiceType -gt ""
$ServiceTypes = $messages | Select-Object ServiceType | Sort-Object ServiceType | Get-Unique -AsString



$instanceCount = ForEach ($ServiceType in $ServiceTypes.ServiceType) {
    $SuspendedCount = ($messages | Where-Object MessageStatus -Like "Suspende*" | Where-Object ServiceType -like "$ServiceType").count

$Properties = [ordered]@{'Name' = $ServiceType.Split(",")[0]; 'SuspendedMsgs' = $SuspendedCount}
New-Object -TypeName PSObject -Property $Properties
}

#Writes summary to json-file
$instanceCount | ConvertTo-Json | Out-File "C:\ESB\Tools\SuspendedMessages.json" -Encoding ascii -Force
