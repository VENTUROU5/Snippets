# Get all computer objects from Active Directory

$Credentials = Get-Credential

$computers = Get-ADComputer -Filter * -Credential $Credentials -Server 192.168.1.254
$Upgradeable = $computers | where {$_.name -notlike "VCSA" -and $_.name -notlike "LAB01"}

# Loop through each computer and force a WSUS update
foreach ($computer in $Upgradeable) {
    $computerName = $computer.Name
    Write-Host "Forcing WSUS update on computer: $computerName"
    
    # Use PowerShell remoting to execute Windows Update on the remote computer
    Invoke-Command -Credential $Credentials -ComputerName $computerName -ScriptBlock {
        # Trigger a WSUS update
        Invoke-WUJob -ComputerName $env:COMPUTERNAME -Script {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            $updateSearchResult = $updateSearcher.Search("IsInstalled=0")

            # Install pending updates
            $updatesToInstall = $updateSearchResult.Updates | Where-Object {
                $_.Title -notlike '*Preview*' -and $_.Title -notlike '*Servicing stack*' -and $_.EulaAccepted -eq $true
            }

            if ($updatesToInstall.Count -gt 0) {
                $installer = $updateSession.CreateUpdateInstaller()
                $installer.Updates = $updatesToInstall
                $installationResult = $installer.Install()

                if ($installationResult.ResultCode -eq 2) {
                    Write-Host "Updates installed successfully."
                } else {
                    Write-Host "Failed to install updates. Result code: $($installationResult.ResultCode)"
                }
            } else {
                Write-Host "No updates to install."
            }
        }
    }
    
    Write-Host "WSUS update forced on computer: $computerName"
}
