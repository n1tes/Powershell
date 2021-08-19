
Function Get-zipGroup {
    param(
        [string[]]$properties = 'Members'
        )

$groups = Get-AADGroup -Filter * -properties $properties

$groups.foreach({
    ## Creating hash table to store output for each $group
    $output = @{}

    ## Start assigning keys to the hashtable
    $output.Groupname = $_.Name

    ## Capture all the group members
    $groupmembers = Get-AADGroupMember -identity $_ | where {$_.objectclass -eq 'user'} | select -ExpandProperty Name

    ## only output custom object if there were members in that group
    if ($groupmembers) {
        $output.Members = $groupmembers
        [pscustomobject]$output
            }
        }) #| format-table -AutoSize
    }
