

cd C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -InfraAzureDirectoryTenantName yourdirectory.onmicrosoft.com -NATIPv4Subnet 172.16.0.0/24 -NATIPv4A


#Enable CredSSP on domain controller
Enable-WSManCredSSP -Role Server

#Enable CredSSP on host
Set-Item wsman:localhost\client\trustedhosts -Value *
Enable-WSManCredSSP -Role Client -DelegateComputer *

$registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy Objects\{459B243A-3AD5-4852-8B41-2AC9CEAA7929}Machine\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly"

$Name = "1"

$value = "WSMAN/*"

IF(!(Test-Path $registryPath))

  {
    New-Item -Path $registryPath -Force | Out-Null

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force | Out-Null
}

 ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}