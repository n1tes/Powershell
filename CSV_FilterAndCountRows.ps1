

$file1 = [System.Collections.ArrayList]@(Import-Csv -Path D:\AllScannerRecipients.csv)
#$file2 = [System.Collections.ArrayList]@(Import-Csv -Path D:\Messagetracereport-2024-06-29-To-07-29.csv)
$outputFile = [System.Collections.ArrayList]@()
foreach($line in $file1)
{
   
    $FirstMatch = Import-Csv -Path D:\Messagetracereport-2024-06-29-To-07-29.csv  | where {$_.Recipient -eq $line.Recipient}

        $outputFile.Add(
            [PSCustomObject]@{
                Recipient=$line.Recipient
                ScannedTimes = $FirstMatch.count  
                
            })}

   
$outputFile | Export-Csv D:\ScriptOutput\output_ScannerRecipients.csv -NoTypeInformation