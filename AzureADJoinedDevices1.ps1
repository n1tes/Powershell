Connect-AzureAD
$Result=@()
$Users = Get-AzureADUser -All $true | Select UserPrincipalName,ObjectId, displayname, state
$Users | ForEach-Object {
$user = $_

Get-AzureADUserRegisteredDevice -ObjectId $user.ObjectId | ForEach-Object {
    if ($_.approximateLastlogontimestamp -gt (get-date).AddDays(-60) -and ($_.DisplayName -notlike "UK*"))
{
    $Result += New-Object PSObject -property @{ 
        'Item Name' = $_.DisplayName
        Category = $null
        'Serial Number' = $null
        Model = $null
        Warranty = $null
        'Purchase Date' = $null
        'Purchase Cost' = $null
        Email = $user.UserPrincipalName
        'Full Name' = $user.displayname
        Location = $user.state
        DeviceOSType = $_.DeviceOSType
        ApproximateLastLogonTimeStamp = $_.ApproximateLastLogonTimeStamp
        Status = $null
        Notes = $null}
}
}
}
$Result | Export-Csv D:\scriptOutput\AzureADJoinedDevices1.csv
