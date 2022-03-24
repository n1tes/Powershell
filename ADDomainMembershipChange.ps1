########################################################################################################################
# The purpose of this script is to report via email if there are any members added or deleted in Domain Admins AD group #
# This script is set to in via task scheduler by name "DomainAdminGroupMembershipChange" on pc zip-pc136 #
# This script compares the Domain Admin Members each day with previous days members #
########################################################################################################################


#Below is the path where the domain admin members will be dumped to a text file
$path = '\\zipaufs01\Department\IT\PowerShell Scripts\AD Auditing\DomainAdmins\'

[string]$currentFileNameStartsWith= Get-Date -format dd-MM-yyyy


# Check current domain group members and dump it to a txt file in above location, which we will use to compare with

Get-ADGroupMember -Identity 'Domain Admins' -Recursive | select -ExpandProperty Name | out-file "$path$currentFileNameStartsWith.txt"


$PreviousDay = (Get-date).AddDays(-1)

[string]$PreviousFileNameStartsWith = Get-Date $PreviousDay -Format dd-MM-yyyy


#Below finds the two files (yesterday's and today's) which we will compare between
$previousFile = Get-ChildItem $path | where {$_.name -eq "$PreviousFileNameStartsWith.txt"} | select -ExpandProperty fullname
$currentFile = Get-ChildItem $path | where {$_.name -eq "$currentFileNameStartsWith.txt"} | select -ExpandProperty fullname


#Compares the files and adds to this variable if any users have been deleted
$deletedUsers = Compare-Object -ReferenceObject (get-content $previousFile) -DifferenceObject (Get-Content $currentFile) |
where {$_.SideIndicator -eq "<="} | Select-Object -ExpandProperty InputObject

#Compares the files and adds to this variable if any users have been added
$addedUsers = Compare-Object -ReferenceObject (get-content $previousFile) -DifferenceObject (Get-Content $currentFile) |
where {$_.SideIndicator -eq "=>"} | Select-Object -ExpandProperty InputObject



# Create empty custom table object
$customTable = New-Object System.Data.DataTable
      
# Add columns
$customTable.Columns.Add() | Out-Null
$customTable.Columns[0].Caption = "Deleted"
$customTable.Columns[0].ColumnName = "Deleted Admins"
  
$customTable.Columns.Add() | Out-Null
$customTable.Columns[1].Caption = "Added"
$customTable.Columns[1].ColumnName = "Added Admins"


#Adds rows for deleted or added users and fills the value for column header created above ""Added Admins" & "Deleted Admins", if any

$deletedUsers | foreach-object { $customTable.Rows.Add(  $_,
                        $null
                                                                             
                        )| Out-Null}


$addedUsers | foreach-object { $customTable.Rows.Add(  $null,
                        $_
                                                                            
                        )| Out-Null}

#Below is the html format used when sending email. this code is directly copied from other scripts on internet.
$Head = @"
<style>
  body {
    font-family: "Arial";
    font-size: 8pt;
    }
  th, td, tr { 
    border: 1px solid #e57300;
    border-collapse: collapse;
    padding: 5px;
    text-align: center;
    }
  th {
    font-size: 1.2em;
    text-align: left;
    background-color: #003366;
    color: #ffffff;
    }
  td {
    color: #000000;
     
    }
  .even { background-color: #ffffff; }
  .odd { background-color: #bfbfbf; }
  h6 { font-size: 16pt; 
       font-color: black;
       font-weight: bold;
       }
 
 text { font-size: 14pt;
        font-color: black;
        }
 }
</style>
"@
 

#Storing all the commands required in sending email in a variable

$subject = "Domain Admin Members Report $currentFileNameStartsWith"
$priority = "Normal"
$smtpServer = "mail.zipindustries.com"
$emailFrom = "ITReport@zipindustries.com"
$emailTo = 'itoperations@zipindustries.com'
$port = 25 
$emailBodyTitle = "Domain Admins modified between $PreviousFileNameStartsWith & $(Get-Date -Format 'dd-MM-yyyy hh:mm:sstt')"

# Email body
[string]$body = [PSCustomObject]$customTable | Select 'Added Admins', 'Deleted Admins' | ConvertTo-HTML -Head $head -Body "<h6> $emailBodyTitle</h6></font>"
 
 
 # Email the report if there is atleast one members changed in either Deleted or Added list

 If ($deletedUsers.count -gt 0 -or $addedUsers.count -gt 0) {
    Send-MailMessage -To $emailTo -Subject $subject -BodyAsHtml $body  -SmtpServer $smtpServer -Port $port -From $emailFrom -Priority $priority
        }
 
 
  
