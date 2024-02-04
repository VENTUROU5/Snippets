# Force push GP patches to all AD Computers
# Removed VCSA from list

$Credentials = Get-Credential

$Computers = Get-ADComputer -Filter * -Server 192.168.1.254 -Credential $Credentials
$Updateable = $Computers | select name | where {$_.Name -notlike "VCSA*"}

# Loop through each computer and force a Group Policy update
foreach ($computer in $Updateable) {
    $computerName = $computer.Name
    Write-Host "Forcing update on computer: $computerName"
    
    # Use PowerShell remoting to execute gpupdate on the remote computer
    Invoke-Command -Credential $Credentials -ComputerName $computerName -ScriptBlock {
        gpupdate /force
    }
    
    Write-Host "Update forced on computer: $computerName"
}
