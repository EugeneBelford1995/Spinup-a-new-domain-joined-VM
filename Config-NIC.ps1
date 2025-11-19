#VM's initial local admin:
[string]$userName = "Changme\Administrator"
[string]$userPassword = 'P@$$w0rd12'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$InitialCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#Get the IP scheme from the Hypervisor itself
$vSW = (Get-VMSwitch | Where-Object {$_.SwitchType -eq "External"}).Name
$NIC = (Get-NetIPConfiguration | Where-Object {$_.InterfaceAlias -like "*$vSW*"}).InterfaceAlias
$GW = (Get-NetIPConfiguration -InterfaceAlias "$NIC").IPv4DefaultGateway.NextHop
$HypervisorIP = (Get-NetIPConfiguration -InterfaceAlias "$NIC").IPv4Address.IPAddress
$Prefix = (Get-NetIPConfiguration -InterfaceAlias "$NIC").IPv4Address.PrefixLength
$HypervisorDNS = (Get-NetIPConfiguration | Where-Object {$_.InterfaceAlias -like "*Testing*"}).DNSServer.ServerAddresses

$FirstOctet =  $HypervisorIP.Split("\.")[0]
$SecondOctet = $HypervisorIP.Split("\.")[1]
$ThirdOctet = $HypervisorIP.Split("\.")[2]
$NetworkPortion = "$FirstOctet.$SecondOctet.$ThirdOctet"

Function Config-NIC
{
    Param
    (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $VMName,
    [Parameter(Mandatory=$true, Position=1)]
    [string] $IP
    )
$IP = "$NetworkPortion.$IP"

#This is here for de-bugging purposes, feel free to remove it once everything is tested & verified
Write-Host "Configuring $VMName to use IP $IP, Gateway $GW, and Prefix $Prefix"

#Set IPv4 address, gateway, & DNS servers
Invoke-Command -VMName "$VMName" {$NIC = (Get-NetAdapter).InterfaceAlias ; Disable-NetAdapterBinding -InterfaceAlias $NIC -ComponentID ms_tcpip6} -Credential $InitialCredObject
Invoke-Command -VMName "$VMName" {$NIC = (Get-NetAdapter).InterfaceAlias ; New-NetIPAddress -InterfaceAlias $NIC -AddressFamily IPv4 -IPAddress $using:IP -PrefixLength $using:Prefix -DefaultGateway $using:GW} -Credential $InitialCredObject
Start-Sleep -Seconds 30
#Invoke-Command -VMName "$VMName" {$NIC = (Get-NetAdapter).InterfaceAlias ; Set-DNSClientServerAddress -InterfaceAlias $NIC -ServerAddresses ("$using:NetworkPortion.101", "$using:NetworkPortion.102", "$using:NetworkPortion.103", "$using:NetworkPortion.104", "8.8.8.8", "1.1.1.1")} -Credential $InitialCredObject
Invoke-Command -VMName "$VMName" {$NIC = (Get-NetAdapter).InterfaceAlias ; Set-DNSClientServerAddress -InterfaceAlias $NIC -ServerAddresses $using:HypervisorDNS} -Credential $InitialCredObject
} #Close Config-NIC function