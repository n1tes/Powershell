Function Get-zipComputer {
    param(
        [string[]]$properties = '*'
        )
    Get-ADComputer -filter * -properties $properties
                    }