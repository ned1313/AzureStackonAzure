#Change Username
Rename-LocalUser -Name $env:USERNAME -NewName Administrator

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Stop-Process -Name Explorer -Force
    Write-Output "IE Enhanced Security Configuration (ESC) has been disabled."
}

Disable-InternetExplorerESC

#Extend C drive
Resize-Partition -DriveLetter C -Size (Get-PartitionSupportedSize -DriveLetter C).sizemax

$adminPassword = ConvertTo-SecureString -String "YourPasswordHere"  -AsPlainText -Force

#Steps 1&2
cd C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -InfraAzureDirectoryTenantName example.onmicrosoft.com -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.2 -NATIPv4DefaultGateway 172.16.0.1 -TimeServer 13.79.239.69 -AdminPassword $adminPassword -Verbose 


#Step 3
(Get-Content c:\CloudDeployment\Roles\PhysicalMachines\Tests\BareMetal.Tests.ps1).replace('-not $isVirtualizedDeployment', '$isVirtualizedDeployment') | Set-Content c:\CloudDeployment\Roles\PhysicalMachines\Tests\BareMetal.Tests.ps1

.\InstallAzureStackPOC.ps1 -Rerun -Verbose
