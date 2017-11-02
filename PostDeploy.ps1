$vhdxPath = "C:\ASDK\Azure Stack Development Kit\CloudBuilder.vhdx"
Mount-VHD -Path $vhdxPath -Passthru -ov mount
$cloudbuilder = Get-Partition | ?{$_.DiskNumber -eq $mount.DiskNumber -and $_.size -gt 1GB}
#CloudDeployment, fwupdate and tools
copy-item -path "$($cloudbuilder.DriveLetter):\CloudDeployment" -Destination "C:\" -Recurse
copy-item -path "$($cloudbuilder.DriveLetter):\fwupdate" -Destination "C:\" -Recurse
copy-item -path "$($cloudbuilder.DriveLetter):\tools" -Destination "C:\" -Recurse

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