$accounts=Get-ADUser -Filter * -properties sAMAccountName, UserPrincipalName, title
foreach ($account in $accounts)
{ 
    if ($accounts.title.startswith("ECM"))
    {
        write-host $account.Name
    }
  }
