$users = Get-ADUser -filter * -SearchBase "OU=IT,OU=Users,OU=Australia,DC=neon,DC=local"
$users #print users just to test
$SourceUser = Get-ADUser ituser1 -Properties memberof
$sourceGroups = $SourceUser.MemberOf


# Iterate over each AD group
Foreach($group in $sourceGroups){
    $thisgroup = $group.split(",")[0].split("=")[1]
    Add-ADGroupMember -Identity $thisgroup -members $users
}

Function Generate-StringPassword($length){
    $characters = "123456789!@#$%^&*()abcdehfhjldsandlhrqpjerpqfASADADGDGHEWTBJKITRF"
    $random = 1..$length | ForEach-Object {Get-Random -Maximum $characters.Length}
    $private:ofs=""
    return [string]$characters[$random]
}

$NewUsers = Get-Content -path C:\RandomNames.txt
foreach($NewUser in $NewUsers) {
    $path = "OU=IT,OU=Users,OU=Australia,DC=neon,DC=local"
    $password = ConvertTo-SecureString -String $(Generate-StringPassword -length 8) -AsPlainText -Force
    $firstname = $NewUser.Split(" ")[0]
    $lastname = $NewUser.Split(" ")[1]
    $username = "$firstname.$lastname"

    # Creating new AD user
    New-ADUser -name "$newuser" -GivenName "$firstname" -Surname "$lastname" -SamAccountName $username -UserPrincipalName $username -AccountPassword $password -Enabled $true -path $path

}
