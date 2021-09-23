SS64
PowerShell 
How-to 

How-to: List the installed software [Get-Programs.ps1]

A script to enumerate the software installed on one or more computers. It will include both 32 bit and 64 bit software.

There are several registry locations where installed software is logged:

64 bit = HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\
32 bit = HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\

There are also equivalent locations for per-user software under HKCU, these are mainly used for things like Browser Plugins, Citrix applications and small utility programs, these are NOT scanned by the script below.

HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\
HKCU\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\

<#
.NOTES
    Name: Get-Programs.ps1 
    Author: Simon Sheppard, based on a script by Sitaram Pamarthi.
    Requires: PowerShell v2 or higher. 
    Version: 
    1.01   23-June-2015 - Initial Release, with export to CSV.
.SYNOPSIS
    List installed Programs on one or more computers.
.DESCRIPTION
    This script retrieves the installed software directly from the registry
    it does not rely on having an SCCM client installed.
.PARAMETER ComputerName
    The computer(s) to be checked, by default the local computer.
.EXAMPLE
    Get-Programs.ps1 workstation64
.LINK
    https://ss64.com/ps/syntax-programs.html
#>

[cmdletbinding()]
param(
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string[]]$ComputerName = $env:computername,
    [string]$OutputFile = "C:\batch\Installed_Programs.csv"
)

BEGIN {
    $UninstallRegKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
    Remove-Item $OutputFile -ErrorAction SilentlyContinue
}

PROCESS {
    function Get-InstalledApps
    # This function will loop through the applications installed on one PC
    # and output one object for each Application with all its properties.
    # optionally saving/appending to a .CSV spreadsheet.
    {
        foreach ($App in $Applications)
        {           
            $AppRegistryKey = $UninstallRegKey + "\\" + $App
            $AppDetails = $HKLM.OpenSubKey($AppRegistryKey)
            $AppGUID = $App
            $AppDisplayName = $($AppDetails.GetValue("DisplayName"))
            $AppVersion = $($AppDetails.GetValue("DisplayVersion"))
            $AppPublisher = $($AppDetails.GetValue("Publisher"))
            $AppInstalledDate = $($AppDetails.GetValue("InstallDate"))
            $AppUninstall = $($AppDetails.GetValue("UninstallString"))
            if(!$AppDisplayName) { continue }
            $OutputObj = New-Object -TypeName PSobject
            $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $Computer.ToUpper()
            $OutputObj | Add-Member -MemberType NoteProperty -Name AppName -Value $AppDisplayName
            $OutputObj | Add-Member -MemberType NoteProperty -Name AppVersion -Value $AppVersion
            $OutputObj | Add-Member -MemberType NoteProperty -Name AppVendor -Value $AppPublisher
            $OutputObj | Add-Member -MemberType NoteProperty -Name InstalledDate -Value $AppInstalledDate
            $OutputObj | Add-Member -MemberType NoteProperty -Name UninstallKey -Value $AppUninstall
            $OutputObj | Add-Member -MemberType NoteProperty -Name AppGUID -Value $AppGUID
            if ($RegistryView -eq 'Registry32')
            {
                $OutputObj | Add-Member -MemberType NoteProperty -Name Arch -Value '32'
            } else {
                $OutputObj | Add-Member -MemberType NoteProperty -Name Arch -Value '64'
            }
            $OutputObj

            # Export to a file
            $OutputObj | export-csv -append -noTypeinformation -path $OutputFile
        }
    }
    
    foreach($Computer in $ComputerName)
    {
        Write-Output "Computer: $Computer" 
        if(Test-Connection -ComputerName $Computer -Count 1 -ea 0)
        {
            # Get the architecture 32/64 bit
            if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ea 0).OSArchitecture -eq '64-bit')
            {
                # If 64 bit check both 32 and 64 bit locations in the registry
                $RegistryViews = @('Registry32','Registry64')
            } else {
                # Otherwise only 32 bit
                $RegistryViews = @('Registry32')
            }

            foreach ( $RegistryView in $RegistryViews )
            {
                # Get the reg key(s) where add/remove program information is stored.
                $HKLM = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,$RegistryView)
                $UninstallRef = $HKLM.OpenSubKey($UninstallRegKey)
                $Applications = $UninstallRef.GetSubKeyNames()

                # Now we have the registry locations, call the function which will enumerate
                # all the applications on this PC
                Get-InstalledApps
            }
        }
    }
}

end {}
For instructions of how to download and run this script see: Run a PowerShell script.

When running this script, provide a path for the Excel/CSV $OutputFile plus the computers to inventory. 
The output will default to "C:\batch\Installed_Programs.csv"

The script returns, the Computer Name, Application Name, Vendor, Installation date, Uninstall key/command, GUID and Architecture (32 or 64 bit).

To access the registry of remote computers, the Remote Regsitry service needs to be running, the Remote Registry service can be enabled and started remotely using SC.exe

This script will only work for software installed using the standard Microsoft Windows Installer routines, while this approach covers most software there will always be a few packages which do things their own way. Commercial software inventory programs typically include the unique signatures and install locations for a large number of popular packages.

Examples

Get a list of all the programs installed on the computers: computer64 and computer65:

PS C:\> ./Get-Programs.ps1 computer64, computer65 -outputfile "C:\reports\software.csv"

Display help:

PS C:\> Get-Help ./Get-Programs.ps1

“In any collection of data, the figure most obviously correct, beyond all need of checking, is the mistake” ~ Finagle's Third Law
