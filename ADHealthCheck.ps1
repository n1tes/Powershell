
$scriptsPath = 'D:\Script\'


$scripts = @(
    'get-zipComputer.ps1'
    'get-zipuser.ps1'
    'get-zipgroup.ps1'
            )
            

## Dot Source all scripts
scripts.foreach({ . "$scriptsPath\$_"})

$output = @{}

$adusers = get-zipuser -properties '*', 'msdS-UserPasswordExpiryTimeComputer'
$adComputers = Get-zipComputer
$adGroups = Get-zipGroup

# Region User passwords to expire soon
$output.ExpiringPasswords = ($adusers | where {
    -Not $_.PasswordNeverExpires -and
    -not $_.PasswordExpired -and
    (((Get-Date) - ([datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed'))).Days -lt 30)}).count
    #endregion

##

$output.TotalComputers = $adComputers.count
$output.TotalUsers = $adUsers.Count
$output.TotalGroups = $Adgroups.Count
$output.UserInDomainAdmins = ($adGroups.where({$_.GroupName -eq 'Domain Admins'})).Members.Count
$Output.Expiredpasswords = ($adusers | where {$_.PasswordExpired}).Count
$Output.LockedOutAccounts = ($adusers | where {$_.Lockedout}).count
$output.PasswordNotSet = ($adusers | where {-not $_.PasswordLastSet}).Count
$output.PasswordNeverExpires = ($adusers | where {$_.PasswordNeverExpires}).Count

[pscustomobject]$output