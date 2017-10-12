#Initialize all disks
get-disk | where{$_.PartitionStyle -eq "RAW"} | Initialize-Disk -PartitionStyle GPT

#Install required features
Add-WindowsFeature Hyper-V,Failover-Clustering, Web-Server -IncludeManagementTools
Add-WindowsFeature RSAT-AD-PowerShell, RSAT-ADDS -IncludeAllSubFeature
Install-PackageProvider nuget

#Change Username
Rename-LocalUser -Name $env:USERNAME -NewName Administrator

#Download ASDK files
mkdir C:\ASDK

Invoke-WebRequest https://aka.ms/azurestackdevkitdownloader -OutFile C:\ASDK\asdk.exe

Restart-Computer -Force