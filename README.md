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
