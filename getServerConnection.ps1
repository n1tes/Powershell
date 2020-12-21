Function Get-ServerConnection {
Param (
$account = 'schen')
Get-WmiObject -computername smaws-fs01 -class win32_serverconnection | where username -match $account | select username,computername,sharename | sort username
}

Get-ServerConnection