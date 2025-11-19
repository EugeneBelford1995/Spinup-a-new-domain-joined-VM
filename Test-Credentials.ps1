Function Test-Creds
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

#test.local Domain Admin:
[string]$userName = "$env:USERDOMAIN\$env:USERNAME"
#[string]$userPassword = $Password
# Convert to SecureString
#[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$DomainCredObject = New-Object System.Management.Automation.PSCredential ($userName, $SecurePassword)
Invoke-Command -VMName "TestFallBack" {hostname ; whoami ; Write-Host "If you can read this then it works :)"} -Credential $DomainCredObject
}