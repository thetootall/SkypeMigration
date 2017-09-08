#Uploading the OAUTH certificate on premises to Skype for Business online
#To create the certificate-based credential
Connect-MsolService; 
Import-Module MSOnlineExtended -force
$CertFile = "$env:SYSTEMDRIVE\OAuthConfig\OAuthCert.cer" 
$objFSO = New-Object -ComObject Scripting.FileSystemObject; 
$CertFile = $objFSO.GetAbsolutePathName($CertFile); 
$cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate 
$cer.Import($CertFile); 
$binCert = $cer.GetRawCertData(); 
$credValue = [System.Convert]::ToBase64String($binCert); 
#This is for Exchange
#$ServiceName = "00000002-0000-0ff1-ce00-000000000000"; 
#This is for Lync
$ServiceName = "00000004-0000-0ff1-ce00-000000000000";
$p = Get-MsolServicePrincipal -ServicePrincipalName $ServiceName 
New-MsolServicePrincipalCredential -AppPrincipalId $p.AppPrincipalId -Type asymmetric -Usage Verify -Value $credValue
#Now let's check 
(get-MsolServicePrincipal -ServicePrincipalName $ServiceName).serviceprincipalnames
get-MsolServicePrincipalCredential -AppPrincipalId $p.AppPrincipalId