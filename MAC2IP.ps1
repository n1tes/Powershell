$MacTable = invoke-command -ComputerName hhill-nvr {arp -a}
$MacArray = @()
ForEach ($m in $MacTable)
{
   
    $split = $m -split '\s+'
    Foreach ($line in $split)
    {
        if ($line.StartsWith(172))
        {
            $MacArray += New-Object psobject -Property @{
            'IP Address' = $split[1]
            'MAC-Address' = $split[2]}
        }
    }
  }
$MacArray | Export-Csv E:\scriptOutput\MAC2IP_HHCCTV.csv -NoTypeInformation




















<#$MacTable = Get-Content E:\mactable.txt
$MacArray = @()
ForEach ($m in $MacTable)
{
    $split = $m -split '\s+'
    $MacArray += New-Object psobject -Property @{
    'IP Address' = $split[1]
    'MAC-Address' = $split[2]}
    
          
}
$MacArray | Export-Csv E:\scriptOutput\macIP.csv -NoTypeInformation#>