$users = Get-ADUser -filter * -SearchBase "OU=IT,OU=Users,OU=Australia,DC=neon,DC=local"
$users
$SourceUser = Get-ADUser ituser1 -Properties memberof
$sourceGroups = $SourceUser.MemberOf


# Iterate over each AD group
Foreach($group in $sourceGroups){
    $thisgroup = $group.split(",")[0].split("=")[1]
    Add-ADGroupMember -Identity $thisgroup -members $users
}
