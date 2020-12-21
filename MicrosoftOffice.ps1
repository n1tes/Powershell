foreach ($computer in (Get-Content "e:\scriptinput\pcRandwick.txt")){
  write-verbose "Working on $computer..." -Verbose
  Invoke-Command -ComputerName "$Computer" -ScriptBlock {
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\O365ProPlusRetail* |
    Select-Object DisplayName, DisplayVersion, Publisher
  } | export-csv e:\scriptoutput\resultsOffice.csv -Append -NoTypeInformation
}