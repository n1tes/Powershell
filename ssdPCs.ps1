
$ListWithComputerNames = get-content "e:\scriptinput\pcrandwick.txt"

foreach($computer in $ListWithComputerNames){
    Get-WmiObject -class Win32_DiskDrive -ComputerName $computer | select pscomputername, model | Export-Csv E:\scriptOutput\ssdPClists.csv -Append -NoTypeInformation
    }