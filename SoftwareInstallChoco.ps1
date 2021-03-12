#Enabling WINRM on remote pc First
$pcname = Read-Host "Enter Computer name"
psexec.exe \\$pcname -s c:\windows\system32\winrm.cmd quickconfig -q

Invoke-Command -ComputerName $pcname {Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex}
Function Install-MySoftware{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$computers,

        [Parameter()]
        [string[]]$Packages
    )

    $livecomputers = [Collections.ArrayList]@()

    foreach ($computer in $computers) {
        if (Test-Connection -ComputerName $computer -quiet -count 1) {
            $null = $livecomputers.Add($computer)
        }
        else {
            Write-Verbose -Message ('{0} is unreachable' -f $computer) -verbose
        }
    }

    $livecomputers | foreach-object {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            $Result = [Collections.ArrayList]@()

            $testchoco = test-path 'c:\programdata\chocolatey'
            if ($testchoco -eq $false) {
                write-verbose -Message "Chocolatey not installed on $($env:COMPUTERNAME)." -Verbose
            }
            # TLS 1.2 is required for chocolatey to install

            $tls = [System.Net.ServicePointManager]::SecurityProtocol.HasFlag([Net.SecurityProtocalType]::tls12)

            if ($tls -eq $false) {
                [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocalType]
            }

            foreach ($package in $using:Packages) {
                choco install $package -y | out-file -FilePath "C:\windows\temp\choco-$package.txt"
                if ($LASTEXITCODE -eq '1641' -or '3010') {
                    # Reference: https://chocolatey.org/docs/commandsinstall#exit-codes
                    # Create new custom object to keep adding information to it

                $Result += New-Object -TypeName psobject -Property @{
                    ComputerName = $Env:COMPUTERNAME
                    InstalledPackage = $package}
                }
                else {
                    Write-Verbose -Message "Packages failed on $($Env:COMPUTERNAME), see logs in C:\windows\temp" -Verbose
                }
            } $Result

        }
    } | Select-Object Computername, InstallPackage | Sort-Object -Property Computername
}

Install-MySoftware -computers $pcname -Packages citrix-workspace, 'zoom', 'googlechrome', 'adobereader', 'microsoft-teams'

#'googlechrome', 'firefox', '7zip' 'vlc', 'notepadplusplus', 'citrix-workspace', 'sysinternals', 'zoom', 'adobereader'

# Invoke-Command -ComputerName randwick-pc-03 {Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex}
# => if chocolatey not installed run this






