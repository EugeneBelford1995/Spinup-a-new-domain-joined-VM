Function New-TestVM
{
    Param
    (
    [Parameter(Mandatory=$true, Position=0)]
    [string]$NewVMName,
    [Parameter(Mandatory=$true, Position=1)]
    [string]$NewVMIP,
    [Parameter(Mandatory=$true, Position=2)]
    #[string]$Password
    [System.Security.SecureString]$SecurePassword
    )

#Domain Admin creds, used to join the new VM to the domain
[string]$userName = "$env:USERDOMAIN\$env:USERNAME"
#[string]$userPassword = PlainTextPassword
# Convert to SecureString
#[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainCredObject = New-Object System.Management.Automation.PSCredential ($userName, $SecurePassword)

Set-Location "C:\VM_Stuff_Share\New_VM"
$ADRoot = (Get-ADDomain).DistinguishedName
$DomainFQDN = (Get-ADDomain).DNSRoot

. .\Create-VM.ps1
Create-VM -VMName $NewVMName
Write-Host "Please wait, the VM is booting up."
Start-Sleep -Seconds 180

New-ADComputer -Name "$NewVMName" -SAMAccountName "$NewVMName" -DisplayName "$NewVMName" -Path "ou=Member Servers,$ADRoot"

#VM's initial local admin:
[string]$userName = "Changme\Administrator"
[string]$userPassword = 'P@$$w0rd12'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$InitialCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

#VM's local admin after re-naming the computer:
[string]$userName = "$NewVMName\Administrator"
[string]$userPassword = 'P@$$w0rd12'
# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$IntermediateLocalCredObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

Set-Location "C:\VM_Stuff_Share\New_VM"

#Config the VM's NIC
. .\Config-NIC.ps1
Config-NIC -VMName "$NewVMName" -IP "$NewVMIP"
Start-Sleep -Seconds 30

#Rename the VM, disable IPv6, & install RSAT
. .\Name-VM.ps1
Name-VM -VMName "$NewVMName" -NewName "$NewVMName"
Start-Sleep -Seconds 120

#Joins the lab domain
Invoke-Command -VMName "$NewVMName" {netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes ; Add-Computer -DomainName $using:DomainFQDN -Credential $using:DomainCredObject -Restart -Force} -Credential $IntermediateLocalCredObject 
Start-Sleep -Seconds 120

Write-Host "The new VM $NewVMName is spun up, domain joined, and ready for action."

} #Close the function