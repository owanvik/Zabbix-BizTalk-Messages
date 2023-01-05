# Zabbix-BizTalk-Messages
Template for monitoring BizTalk Messages with scripts

Installation:
1. Create C:\ESB\Tools on the BizTalk Management server (or any server that can talk to the BizTalk environment)

Scheduled tasks:
2. Create a scheduled task that runs 'powershell.exe -ExecutionPolicy Bypass "<path>\CountActiveMessages.ps1"' 
3. Create a scheduled task that runs 'powershell.exe -ExecutionPolicy Bypass "<path>\CountInstanceStatuses.ps1"'
4. Create a scheduled task that runs 'powershell.exe -ExecutionPolicy Bypass "<path>\CountSuspendedMessages.ps1"'
Schedule the tasks to run at some point each day, and every 5 minutes for a duration of 1 day.
All the tasks must be run with a user that have read access to the BizTalk environment

5. Import the Zabbix Template to Zabbix
6. Add the template to the host running the scripts
  
  
Some of the macros are "User macro with context" which you can read about here:
https://www.zabbix.com/documentation/current/en/manual/config/macros/user_macros_context

Example: {$ACTIVE.INST.COUNT.CRIT:"MyBT.ServiceType"} This will override the default {$ACTIVE.INST.COUNT.CRIT} macro for "MyBT.ServiceType". 
To use this you create a new macro like {$ACTIVE.INST.COUNT.CRIT:"MyBT.ServiceType"} and replace "ServiceType" with the ServiceType of the application you want to override.
You can find the service type in the name of the item in Zabbix, or by running this script in powershell:
```powershell
$mgmtDbServer = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.Operations")
$mgmtDbName = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
$getBodyOperation = New-Object Microsoft.BizTalk.Operations.BizTalkOperations($mgmtDbServer, $mgmtDbName)
$ServiceTypes = $getBodyOperation.GetMessages() | Where-Object ServiceType -gt "" | Select-Object ServiceType

$output = ForEach ($ServiceType in $ServiceTypes.ServiceType) {
$Properties = [ordered]@{'Name' = $ServiceType.Split(",")[0]}
New-Object -TypeName PSObject -Property $Properties
}
$output
  ```
  
