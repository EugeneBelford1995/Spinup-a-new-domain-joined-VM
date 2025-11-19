# Spinup-a-new-domain-joined-VM
Automates creating, configuring, and domain joining a new VM

This assumes that your server that will run your hypervisor [either Hyper-V Server or Windows Server with Hyper-V enabled] is domain joined and uses the same IP scheme as your domain VMs. It also assumes that you use static IPs, at least for VMs that are servers.

Pre-Reqs.ps1 creates the folder structure, enables Hyper-V if it's not already, creates a vSW and maps it to an active NIC if the vSW doesn't exist already, and grabs a copy of Windows Server 2022 from Microsoft.
DO NOT run Pre-Reqs.ps1 if you have a vSW already created and mapped to your only active NIC. It checks if a vSW named "Testing" already exists, not if any vSW exists. 

Put the files in this repository in C:\VM_Stuff_Share\New_VM. 

Do ' . . C:\VM_Stuff_Share\New_VM\New-VM_Test_Domain.ps1' to import the function.

Run it via 'New-TestVM -NewVMName "<name>" -NewVMIP "<IP>".

For example:
New-TestVM -NewVMName "TestFallback" -NewVMIP "106"

Please note you must run the function as a user who has rights both to manage Hyper-V and join systems to the domain.

The function pulls your current domain\username, prompts for your password, and saves it in a securestring and a pscredential to use to domain join the VM.
