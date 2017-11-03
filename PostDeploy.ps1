<#
  This file is meant to be run in stages to complete the Azure Stack deployment.
  1. Be sure the change the tenant name in the first deployment command to your targeted deployment
  2. Run the deployment until it errors out (it will extract the file that needs to be altered in the next step)
  3. Update the BareMetal.Tests.ps1 file and restart the configuration
  4. Run the commands in step 4.  You will be prompted for the AzureStackAdmin credentials
  
#>

#Steps 1&2
cd C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -InfraAzureDirectoryTenantName example.onmicrosoft.com -NATIPv4Subnet 172.16.0.0/24 -NATIPv4Address 172.16.0.2 -NATIPv4DefaultGateway 172.16.0.1 -TimeServer 13.79.239.69 -Verbose


#Step 3
(Get-Content c:\CloudDeployment\Roles\PhysicalMachines\Tests\BareMetal.Tests.ps1).replace('-not $isVirtualizedDeployment', '$isVirtualizedDeployment') | Set-Content c:\CloudDeployment\Roles\PhysicalMachines\Tests\BareMetal.Tests.ps1

.\InstallAzureStackPOC.ps1 -Rerun -Verbose

#Step 4
#Enable CredSSP on domain controller
$cred = Get-Credential -Message "Enter AzureStackAdmin credentials" -UserName "AzureStackAdmin@azurestack.local"
invoke-command -ComputerName AzS-DC01 -Credential $cred -ScriptBlock { Enable-WSManCredSSP -Role Server -Force}

#Enable CredSSP on host
Set-Item wsman:localhost\client\trustedhosts -Value * -Force
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force

#Additional settings for GP
Set-ExecutionPolicy Unrestricted -Force
Install-Module -Name PolicyFileEditor -Force
$MachineDir = "$env:windir\system32\GroupPolicy\Machine\registry.pol"

#Fix DNS issues
$dNIC = Get-NetAdapter -Name "Deployment"
$DNS = Get-DnsClientServerAddress -InterfaceIndex $dNIC.ifIndex
Set-DnsClientServerAddress -InterfaceIndex $dnic.ifIndex -ResetServerAddresses

#Set up the BGP NAT Switch
New-VMSwitch -Name "NATSwitch" -SwitchType Internal -Verbose
$NIC = Get-NetAdapter -Name "vEthernet (NATSwitch)"
New-NetIPAddress -IPAddress 172.16.0.1 -PrefixLength 24 -InterfaceIndex $NIC.ifIndex
New-NetNat -Name "NATSwitch" -InternalIPInterfaceAddressPrefix "172.16.0.0/24" –Verbose

#Set BGP VM to use NATSwitch
$vmnic = Get-VMNetworkAdapter -VMName AzS-BGPNAT01 -Name NAT
Connect-VMNetworkAdapter -VMNetworkAdapter $vmnic -SwitchName NATSwitch

#Add an adapter to the AzS-DC01 machine
$vm = Get-vm -VMName AzS-DC01
Add-VMNetworkAdapter -VMName $vm.Name -SwitchName NATSwitch

#Run commands for second adapter
$cred = Get-Credential -Message "Enter AzureStackAdmin credentials" -UserName "AzureStackAdmin@azurestack.local"
invoke-command -ComputerName AzS-DC01 -Credential $cred -ScriptBlock { New-NetIPAddress -IPAddress 172.16.0.4 -InterfaceIndex (Get-NetAdapter -Name "Ethernet 2").ifIndex -DefaultGateway 172.16.0.1 -AddressFamily IPv4 -PrefixLength 24}


#Restart Azure Stack Install
.\InstallAzureStackPOC.ps1 -Rerun -Verbose