$osInfo = Get-ComputerInfo 
If ($osInfo.OsName -like "*Server*") 
{
Write-Output "Setting up Hyper-V and a vSW on Windows Server"
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools

If (Get-VMSwitch -Name Testing){Write-Host "vSW already exists"}
Else
{
$NIC = Get-NetAdapter | Where-Object {($_.Name -like "Ethernet*") -and ($_.Status -eq "Up")}
New-VMSwitch -Name "Testing" -NetAdapterName "$NIC" ; Set-VMSwitch -Name Testing -AllowManagementOS $true
Write-Host "vSW Testing has been created and mapped to NIC $NIC"
}
}

Else 
{
Write-Output "Setting up Hyper-V and using the Default Switch on Windows 10"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}

New-Item "C:\VM_Stuff_Share\New_VM" -ItemType Directory
New-Item "C:\VM_Stuff_Share\ISOs" -ItemType Directory
Write-Host "Grab a x64 ISO from https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022 and save it in the ISOs folder."

If("C:\VM_Stuff_Share\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"){Write-Host "ISO is already downloaded"}
Else{Invoke-WebRequest -Uri "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso" -OutFile "C:\VM_Stuff_Share\ISOs\Windows Server 2022 (20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us).iso"}
Install-Module -Name Convert-WindowsImage

Write-Host "If the above fails to install Convert-WindowsImage then download it from https://github.com/x0nn/Convert-WindowsImage"
Write-Host "Save it in C:\VM_Stuff_Share\New_VM"