Function New-User {
    [CmdletBinding()] param(
    [Parameter(Mandatory=$True,Helpmessage="Enter the Firstname and Last name of new user")]
    
    $Firstname, $Lastname)

$SourceUser = get-aduser -identity ituser1 -properties Office, homepage, company, department, officephone, pager, title, streetaddress

$Fname = $Firstname.substring(0,1).toupper()+$Firstname.substring(1).tolower()
$Lname = $Lastname.substring(0,1).toupper()+$Lastname.substring(1).tolower()
$Fullname = $Firstname + " " + $Lastname
$SAM1 = $Firstname.substring(0,1) + $Lastname
$SAM2 = $Firstname.substring(0,2) + $Lastname
$dnsroot = '@' + (Get-ADDomain).dnsroot
$Password = (ConvertTo-SecureString -AsPlainText "Monte2031" -Force)
$UPN1 = $SAM1 + "$dnsroot"
$UPN2 = $SAM2 + "$dnsroot"
$OU = "OU=IT,OU=Users,OU=Australia,DC=neon,DC=local"
$Email1 = $SAM1 + "$dnsroot"
$Email2 = $SAM2 + "$dnsroot"

if (!(Get-ADUser -filter {samaccoutname -eq "$SAM1"}))
{
$Parameters1 = @{
Samaccountname = $SAM1
UserPrincipalName = $UPN1
Name = $Fullname
Emailaddress = $Email1
Givenname = $Fname
Surname = $Lname
AccountPassword = $Password
ChangePasswordAtLogon = $True
Enabled = $True}

New-ADUser @Parameters1 -Instance $SourceUser
}

elseif ((Get-ADUser -filter {samaccoutname -eq "$SAM1"}))
{
$Parameters2 = @{
Samaccountname = $SAM2
UserPrincipalName = $UPN2
Name = $Fullname
Emailaddress = $Email2
Givenname = $Fname
Surname = $Lname
AccountPassword = $Password
ChangePasswordAtLogon = $True
Enabled = $True}

New-ADUser @Parameters2 -Instance $SourceUser

}
    

#write-host $Email




}

