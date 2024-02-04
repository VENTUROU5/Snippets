# Define the module name to install
$moduleName = "YourModuleName"

# List of remote computer names
$remoteComputers = @("Computer1", "Computer2", "Computer3")

# Loop through each remote computer and install the module
foreach ($computer in $remoteComputers) {
    Write-Host "Installing module '$moduleName' on computer: $computer"

    # Use PowerShell remoting to install the module
    Invoke-Command -ComputerName $computer -ScriptBlock {
        param($moduleName)

        # Install the specified module
        Install-Module -Name $moduleName -Force -Scope CurrentUser

    } -ArgumentList $moduleName

    Write-Host "Module '$moduleName' installed on computer: $computer"
}