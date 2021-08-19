
Function Get-zipUser {
    param(
        [string[]]$properties = '*'
        )
    Get-Aduser -filter * -properties $properties
                    }