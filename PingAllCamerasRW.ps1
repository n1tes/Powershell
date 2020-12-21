$ip = Get-Content E:\scriptInput\IPlistCameraRW.txt
foreach ($address in $ip)
{
    ping -n 1 $address

}
   
