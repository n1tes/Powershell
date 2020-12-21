
$ListWithComputerNames = get-content "e:\scriptinput\pcrandwick.txt"

foreach($computer in $ListWithComputerNames){
    psexec.exe \\$computer -s c:\windows\system32\winrm.cmd quickconfig -q
    }