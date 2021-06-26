Function Get-OSinfo {
    [Cmdletbinding()]
    param(
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True,
                    HelpMessage="The. Computer. Name.")]
        [string[]]$computername
    )
    BEGIN {} ##Begin, process & End block is only required for Valuefrom Pipeline property
    ## otherwise it only outputs the last output in pipeline
    PROCESS {
    foreach ($computer in $computername)
    {
        try {
            $cimsession = New-CimSession -ComputerName $computer -ErrorAction stop
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session
            $cs = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $session
            $properties = @{
                            ComputerName = $computer
                            Status = 'Connected'
                            SPVersion = $os.ServicePackMajorVersion
                            OSVersion = $os.Version
                            Model = $cs.Model
                            mfgr = $cs.Manufacturer
                            }
            } catch {
            Write-Verbose "couldn't connect $computer"
            $properties = @{
                            ComputerName = $computer
                            Status = 'Disconnected'
                            SPVersion = $null
                            OSVersion = $null
                            Model = $null
                            mfgr = $null
                            }
        
                    } Finally {
                    $obj = [pscustomobject]$properties
                    Write-Output $obj
    
                              }

    }
    }
    END {}
}