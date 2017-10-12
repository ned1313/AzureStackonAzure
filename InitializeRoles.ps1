
Add-WindowsFeature Failover-Clustering, Web-Server -IncludeManagementTools
Add-WindowsFeature RSAT-AD-PowerShell, RSAT-ADDS -IncludeAllSubFeature
Install-PackageProvider nuget –Verbose

Write-Output "Required features have been installed, system will now reboot"

Wait-Event -Timeout 5

Restart-Computer -Force