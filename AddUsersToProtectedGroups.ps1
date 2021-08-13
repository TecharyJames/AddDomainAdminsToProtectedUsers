#############################
## James Tarran // Techary ##
#############################

$ErrorActionPreference = 'SilentlyContinue'

param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit

}

function print-TecharyLogo {
        
    $logo = "
     _______        _                      
    |__   __|      | |                     
       | | ___  ___| |__   __ _ _ __ _   _ 
       | |/ _ \/ __| '_ \ / _`` | '__| | | |
       | |  __/ (__| | | | (_| | |  | |_| |
       |_|\___|\___|_| |_|\__,_|_|   \__, |
                                      __/ |
                                     |___/ 
"

write-host -ForegroundColor Green $logo

}

function list-members{

    Write-host "Listing members of Domain admins..."

    start-sleep 1

    Get-ADGroupMember -Identity "Domain Admins"

    start-sleep 1

    Write-host "Listing members of Protected Users..."
    Write-host " "

    start-sleep 1

    Get-ADGroupMember -Identity "Protected Users"

    start-sleep 1

}

function compare-members{

    $DAU = get-content -path C:\DAU.txt

    $PUU = get-content -path C:\PUU.txt

    $diff = Compare-Object $DAU $PUU
    if ($PUU -eq $null -or $diff)
        {
        Write-host "At least some Domain Admins not present in protected users. Adding..."
        add-ProtectedMembers
        }
    else
        {
        write-host "Domain admins already members of Protected Users"
        cleanUpAndExit
        }
}

function compare-membersAgain {

    $DAU = get-content -path C:\DAU.txt

    $PUU = get-content -path C:\PUU.txt

    $diff = Compare-Object $DAU $PUU
    if ($PUU -eq $null -or $diff)
        { 
        write-warning "Members not added, please run the script again"
        cleanUpAndExit 
        }
    else
        { 
         write-host " "
        write-host "Members added successfully!"
        }
}

function add-ProtectedMembers {
    
    Get-ADGroupMember -Identity "Domain Admins" | ForEach-Object {Add-ADGroupMember -Identity "Protected Users" -Members $_.distinguishedName}

}

function get-groupMembers {

    Get-ADGroupMember -Identity "Domain Admins" | select SID | out-file C:\DAU.txt

    Get-ADGroupMember -Identity "Protected Users" | select SID | out-file C:\PUU.txt

}

function cleanUpAndExit {

    Remove-Item -Recurse -path C:\DAU.txt

    Remove-Item -Recurse -path C:\PUU.txt

    exit

}

# ---------------------------------------------------------------------------------------------------

print-TecharyLogo

import-module activedirectory

list-members

get-groupMembers

compare-members

get-groupMembers

compare-membersAgain

cleanUpAndExit