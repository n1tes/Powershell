
### This script updates the existing record's rowID column with auto incrementing number from 1

#Register-PnPManagementShellAccess
$siteurl = "https://zipindustries.sharepoint.com/sites/StockTake2021"

#Connecting to the shareppoint site.
#Connect-PnPOnline -url $siteurl -UseWebLogin
Connect-PnPOnline -url $siteurl -Interactive
 
 # Only find the lists with name starting with "stock_"
 $allLists = Get-PnPList | where {$_.title -like "stock_*"} | select -ExpandProperty Title

 Foreach ($list in $allLists){
     Add-PnPField -List $list -type Number -DisplayName "rowID" -InternalName "rowID" -AddToDefaultView

 $allItems = get-pnplistitem -list $list #-PageSize 500 #Get every item in that list
 
 $i = 1 #Setting a counter to start with 1
 

    #Storing all the records in the list with its corresponding values
    ForEach ($item in $allItems){
        
        
        #write-host $i " " $list

        Set-PnPListItem -list $list -Identity $item -Values @{
            "rowID" = $i}
        #Add-PnPListItem  -List $list -Values @{
            #"rowID" = $i}
        $i++
       
    }
    
}



