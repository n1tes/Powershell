Function Get-PCInfo {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="The. PC. Name.")]
        [string[]]$PCName
    )
    BEGIN {} ##Begin, process & End block is only required for Valuefrom Pipeline property
    ## otherwise it only outputs the last output in pipeline
    PROCESS {
    foreach ($PC in $PCName)
    {
        try {
            $session = New-CimSession -ComputerName $PC -ErrorAction stop
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session
            $cs = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $session
            $bios = Get-CimInstance -ClassName Win32_BIOS -CimSession $session
            $processor = Get-CimInstance -ClassName Win32_Processor -CimSession $session | Select-Object -ExcludeProperty "CIM*"
            $disk =  Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $session -Filter "DriveType=3"
            $memory = Get-CimInstance Win32_PhysicalMemory -CimSession $session
            $properties = [ordered]@{
                            ComputerName = $PC
                            Manufacturer = $bios.Manufacturer
                            Model = $cs.Model
                            SerialNumber = $bios.SerialNumber
                            Memory = (($memory | Measure-Object -Property capacity -Sum).sum /1GB).ToString()+" GB"
                            "CPU/Processor" = $processor.Name
                            OS = $os.Caption
                            OSVersion = $os.Version
                            OSInstallDate= $os.InstallDate
                            "PrimaryDisk(C)" = ([Math]::Round($disk[0].Size/1GB)).ToString()+" GB"
                            PrimaryDiskUsage = ([Math]::Round($disk[0].Size/1GB) - [Math]::Round($disk[0].FreeSpace/1GB)).ToString()+"/"+[Math]::Round($disk[0].Size/1GB)+" GB"
                            LastBootUpTime = $os.LastBootUpTime
                            IPAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet*").IPaddress
                            Status = 'Connected'                    
                            
                            
                            }
            } catch {
            Write-Verbose "couldn't connect PC"
            $properties = @{
                            ComputerName = $PC
                            Manufacturer = $null
                            Model = $null
                            SerialNumber = $null
                            Memory = $null
                            "CPU/Processor" = $null
                            OS = $null
                            OSVersion = $null
                            OSInstallDate= $null
                            "PrimaryDisk(C)" = $null
                            PrimaryDiskUsage = $null
                            LastBootUpTime = $null
                            IPAddress = $null
                            Status = 'Disconnected' 
                            }
        
                    } Finally {
                    $obj = [pscustomobject]$properties
                    Write-Output $obj
    
                              }

    }
    }
    END {}
}