$ip = read-host "Enter IP to ping"
$fileName = read-host "Give a file name"
$noOfPackets = read-host "How many ping requests to send? "
ping -n $noOfPackets $ip |
Foreach{"{0} - {1}" -f (Get-Date),$_} > e:\scriptOutput\$fileName.txt