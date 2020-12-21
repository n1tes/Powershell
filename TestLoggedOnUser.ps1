#$pc = Get-ADComputer -filter * | select -ExpandProperty name
$pc = Get-ADComputer -Filter 'Name -like "randwick-pc-*"' | select -ExpandProperty name

foreach ($computer in $pc)
{
    $compsystem = Get-WmiObject -ComputerName $computer -class win32_computersystem 
  
   $hash = @{
   'user' = $compsystem.username;
   'computer' = $compsystem.name;}

   $outobj = New-Object -TypeName psobject -Property $hash
   Write-Output $outobj | ft 
}
    
    

#    $a
#   # New-Object psobject -property @{
#   #
   # '$userName' = Get-WmiObject -ComputerName $computer -class win32_computersystem | select username 
   # '$Name' = Get-WmiObject -ComputerName $computer -class win32_computersystem | select name
   # }}



#write-host $computer}


#Get-WmiObject -ComputerName $computer -class win32_computersystem | select username,name