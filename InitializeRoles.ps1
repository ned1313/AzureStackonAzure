#Disable InternetExplorerESC
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Output "IE Enhanced Security Configuration (ESC) has been disabled."
}

Disable-InternetExplorerESC

#Initialize all disks
get-disk | where{$_.PartitionStyle -eq "RAW"} | Initialize-Disk -PartitionStyle GPT

#Extend C drive
Resize-Partition -DriveLetter C -Size (Get-PartitionSupportedSize -DriveLetter C).sizemax

#Install required features
Add-WindowsFeature Hyper-V,Failover-Clustering, Web-Server -IncludeManagementTools
Add-WindowsFeature RSAT-AD-PowerShell, RSAT-ADDS -IncludeAllSubFeature
Install-PackageProvider nuget -Force

#Change Username
Rename-LocalUser -Name $env:USERNAME -NewName Administrator

#Download ASDK files
mkdir C:\ASDK

Invoke-WebRequest https://aka.ms/azurestackdevkitdownloader -OutFile C:\ASDK\asdk.exe
$resp = Invoke-RestMethod -Method Get https://aka.ms/azurestack-asdkdownloads
$resp2 = Invoke-RestMethod -Method Get -Uri $resp.DownloadProduct.DownloadReleases.Uri
foreach($file in $resp2.DownloadFileList.Files)
{
    Start-BitsTransfer -Source "$($resp2.DownloadFileList.DownloadSource)$($file.FileName)" -Destination "C:\asdk\$($file.FileName)" -Asynchronous
}

do{
    $bits = Get-BitsTransfer | ?{$_.jobstate -ne "transferred"}
}while($bits.count -gt 1)

Get-BitsTransfer | Complete-BitsTransfer



Restart-Computer -Force