####Exchange Online (Plan 1) i.e E1 license is EXCHANGE_S_STANDARD  #### Created 30-01-25
####Exchange Online (Plan 2) which is what M365 E3 users have is EXCHANGE_S_ENTERPRISE  #### Created 30-01-25

# Connect to Microsoft Graph using Connect-MgGraph
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"

# Get all users using Get-MgUser with a filter
$users = Get-MgUser -All -Property AssignedLicenses, LicenseAssignmentStates, DisplayName | Select-Object DisplayName, AssignedLicenses -ExpandProperty LicenseAssignmentStates | Select-Object DisplayName, AssignedByGroup, State, Error, SkuId

$output = @()

# Loop through all users and get the AssignedByGroup Details which will list the groupId
foreach ($user in $users) {
    # Get the group ID if AssignedByGroup is not empty
    if ($user.AssignedByGroup -ne $null)
    {
        $groupId = $user.AssignedByGroup
        $groupName = Get-MgGroup -GroupId $groupId | Select-Object -ExpandProperty DisplayName  
        Write-Host "$($user.DisplayName) is assigned by group - $($groupName)" -ErrorAction SilentlyContinue -ForegroundColor Yellow
        $result = [pscustomobject]@{
            User=$user.DisplayName
            AssignedByGroup=$true
            GroupName=$groupName
            GroupId=$groupId
        }
        $output += $result
    }

else {
    $result = [pscustomobject]@{
            User=$user.DisplayName
            AssignedByGroup=$false
            GroupName="NA"
            GroupId="NA"
        }
        $output += $result
        Write-Host "$($user.DisplayName) is Not assigned by group" -ErrorAction SilentlyContinue -ForegroundColor Cyan
    }
        
    
}

# Display the result
$output | export-csv N:\M365LicensesForAll.csv -NoTypeInformation