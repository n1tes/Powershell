
###Below is working as of 19/09/24####
#where {$_.userprincipalname -Notlike "*onmicrosoft*" -or $_.userprincipalname -Notlike "*zipindustries*" -or $_.GivenName -ne $null} |

Connect-MgGraph -ClientId 5f5e64db-a09b-4099-8113-667ab2626292 -TenantId zipindustries.onmicrosoft.com -CertificateThumbprint 2423E67FF79BABCF726D7C6187752078CCD77EF1

$allLicensedUsers = @()

  #E3 users 
 $allLicensedUsers += Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq 05e9a617-0261-4cee-bb44-138d3ef5d965)"  -All -Property GivenName, Surname, UserPrincipalName, EmployeeID, CompanyName, Country, JobTitle 
 

  #Get F1 users
 $allLicensedUsers += Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq 50f60901-3181-4b75-8a2c-4c8e4c1d5a72)"  -All -Property GivenName, Surname, UserPrincipalName, EmployeeID, CompanyName, Country, JobTitle 
 

  #Get F3 users
 $allLicensedUsers += Get-MgUser -Filter "assignedLicenses/any(x:x/skuId eq 66b55226-6b4f-492c-910c-a3b7a3c9d993)"  -All -Property GivenName, Surname, UserPrincipalName, EmployeeID, CompanyName, Country, JobTitle
 

$string = ""
Foreach ($licensedUser in $allLicensedUsers) {

    If($licensedUser.JobTitle -ne $null -and $licensedUser.UserPrincipalName -notlike "*onmicrosoft.com" `
       -and $licensedUser.JobTitle -notlike "*test*" -and $licensedUser.UserPrincipalName -notlike "itunes@zipwater.com" `
        -and $licensedUser.UserPrincipalName -notlike "super.market@zipwater.com" -and $licensedUser.UserPrincipalName -notlike "indpc@zipwater.com" `
 -and $licensedUser.UserPrincipalName -notlike "*noreply*" `
-and $licensedUser.UserPrincipalName -notlike "scanner@culligan.com.au") {

    
    $string += $($licensedUser.UserPrincipalName)+","+" EmpID: "+$($licensedUser.EmployeeID)+"|"



}}

$NewValues = @{
        "question[text]" = "Select Employee To Terminate"
        "question[order]" = 2
        "question[options]" = $string}





$URLZip = "https://zipwater.jotform.com/API/form/242128222698964/question/148?apikey=28a2bbdd7acc9ce7ed8b798b79a7a76e"
 

#Invoke-RestMethod -Uri $URLZip -Method Get

       
    
   
Invoke-RestMethod -Uri $URLZip -Method Post -Body $NewValues -ContentType "application/x-www-form-urlencoded"
    
    
    
    #Invoke-RestMethod -Uri $URLZip -Method Get
        

