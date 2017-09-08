#Developed by Chris Blackburn
#http://www.memphistech.net

$userSIP = Read-Host "Enter user email address to migrate"
$tenant = Read-host "Enter your vanity domain, including .onmicrosoft.com"
$frontend = Read-host "Enter your on-prem front end pool"

#I cannot enumerate this one at this time, please log into your Admin center to grab the URL
$SkypePool = "https://admin2a.online.lync.com/"
$SkypeURL = $SkypePool + "HostedMigration/hostedmigrationService.svc"

#Load on-premises Skype for Business Server powershell
Import-module Lync

#Connect to Skype for Business online Powershell and assign prefix
#If you don't have the module please download from:
#https://www.microsoft.com/en-us/download/details.aspx?id=39366

$cred = get-credential
Import-Module SkypeOnlineConnector
$cssession = new-CsOnlineSession -Credential $cred -OverrideAdminDomain $tenant
Import-PSSession $CSSession -Prefix o365

#If successful convert the contact store

if((Test-CsExStorageConnectivity -SipUri grich@imris.com) -eq $true) 
Invoke-CsUcsRollBack $userSIP -verbose

#Assign this new per-user policy (NoUnifiedContactStore) by using a command like this:
Grant-CsUserServicesPolicy -Identity $userSIP -PolicyName MigratetoCloud
} 

if (((Debug-CsUnifiedContactStore -Identity $UserSIP).UCSMode -eq "Disabled") -and ((Get-CsUser -identity $usersip).UserServicesPolicy).Friendlyname -eq "MigratedToCloud")
{write-host "User ready for migration; beginning:"

#Use On-prem Skype for Business Powershell to move the user
Move-CsUser -Identity $userSIP -Target sipfed.online.lync.com -Credential $creds -HostedMigrationOverrideUrl $SkypeURL  –ProxyPool $frontend -Verbose

#Use On-prem Skype for Business Powershell to change the user's voice routing policy
Grant-CsVoiceRoutingPolicy -Identity $userSIP -PolicyName HybridVoice

#Use Skype for Business Powershell Online to change the user's voice configuration
Set-o365CsOnlineUser -Identity $userSIP -EnterpriseVoiceEnabled $true

#Still haven't figured out the replacement for -HostedVoiceMail $true so I'm leaving this here...
}
else
{write-host "False"
write-host "debug: UCSMode is: " (Debug-CsUnifiedContactStore -Identity $UserSIP).UCSMode
write-host "debug: Friendlyname is: " ((Get-CsUser -identity $usersip).UserServicesPolicy).Friendlyname
}