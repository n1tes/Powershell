foreach ($ip in 20..25 ){
if(($a=test-NetConnection 172.19.115.$ip).pingsucceeded -eq $false) 
{"hgjgg 172.19.115.$ip"}

 }