<#
.SYNOPSIS
Gets Stuff from places
.DESCRIPTION
Uses WMI to get stuff from places.
.PARAMETER computername
A computer name, or IP address, to query
.EXAMPLE
Get-OSInfo -computername WIN8
.EXAMPLE
Get-OSInfo WIN8
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$computername
)
Write-Verbose "Attempting connection to $computername"
$user = Get-WmiObject -class win32_computersystem -ComputerName $computername 
$os = Get-ciminstance -class win32_operatingsystem -ComputerName $computername
$windows = Get-WmiObject Win32_OSRecoveryConfiguration -ComputerName $computername
$bios = Get-WmiObject -class win32_BIOS -ComputerName $computername
$physicaldisk = Get-WmiObject -class Win32_DiskDrive -ComputerName $computername
$logicaldisk = Get-WmiObject -class Win32_LogicalDisk -ComputerName $computername | where {$_.DeviceID -eq "c:"}

Write-Verbose "Building property list"
$props = @{'ComputerName'=$computername;
            'LoggedUser' = $user.username;
            'Brand'= $bios.manufacturer;
            'OSVersion'= $os.version;
            'OSArchitecture'= $os.OSarchitecture;
            'Operating_System'= ($windows| Select-Object -ExpandProperty name).substring(0,24);
            'BIOSSerial'= $bios.serialnumber;
            'DiskModel'= $physicaldisk.model;
            'DiskSize_GB'= $physicaldisk.size/1gb -as [int]
            'FreeSpace_GB'= $logicaldisk.FreeSpace/1gb -as [int]
            'LastBootUpTime' = $os.LastBootUpTime
            }

$obj = New-Object -TypeName psobject -Property $props
Write-Verbose "Outputting custom property"
write-output $obj

