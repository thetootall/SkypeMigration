#Developed by Chris Blackburn
#http://www.memphistech.net

#Run this from your on-premises Skype for Business Server
Import-module Lync

#First we remove the existing Exchange on-premises partner connections
Remove-CsPartnerApplication *Exchange*

#Next we create a new partner application that utilizes Exchange Online
New-CsPartnerApplication -Identity microsoft.exchange -ApplicationIdentifier 00000002-0000-0ff1-ce00-000000000000 -ApplicationTrustLevel Full –UseOAuthServer

#We create a User Services Policy with UCS disabled
New-CsUserServicesPolicy -Identity MigratetoCloud -UcsAllowed $False

#Finally we update the Skype for Business OAUTH with the current Exchange Online Autodiscover URL
Set-CsOAuthConfiguration -ExchangeAutodiscoverUrl "https://autodiscover-s.outlook.com/autodiscover/autodiscover.svc"