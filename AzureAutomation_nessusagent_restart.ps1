Write-Output "Connecting to azure via Connect-AzAccount -Identity"
Connect-AzAccount -Identity 
Set-AzContext -Subscription "####################################"
Write-Output "Successfully connected with Automation account's Managed Identity"

# Script which should run inside the Azure VMs

$scriptCode = @'
$nessusCliPath = "C:\Program Files\Tenable\Nessus Agent\nessuscli.exe"
$maxIterations = 3
$iteration = 1

$logparameters = @{
    "LogName" = "Application"
    "Source"  = "############"
}
$logparametersVar = $logparameters

New-EventLog -LogName "Application" -Source "############" -ErrorAction SilentlyContinue

:OuterLoop while ($iteration -le $maxIterations) {

    if (Test-Path -Path $nessusCliPath) {
        Write-Output "Path exists. Continuing loop iteration $($i)"
        # Continue with your logic here for this iteration
    }
    else {
        Write-Output "Path does not exist. Breaking loop at iteration $($i)"
        $logparametersVar += @{
            "EventId"   = "3"
            "Entrytype" = "Error"
            "Message"   = "Agent Status: Agent Not Installed"
        }
        Write-EventLog @logparametersVar
        $logparametersVar = $logparameters
        break OuterLoop  # Exit both loops if agent status is OK
    }



    Write-Host "Iteration $iteration"

    $agentStatus = & $nessusCliPath agent status

    if ($agentStatus -match "Link status: Not linked to a manager") {
        Write-Host "Agent status: Error"
        Write-Host "Restarting Nessus Agent..."
        & $nessusCliPath agent link --key=############################################################ --host=################################################ --groups=############ --port=############
        $logparametersVar += @{
            "EventId"   = "1"
            "Entrytype" = "Information"
            "Message"   = "Agent Status: Not linked to manager... Restarting. Attempt Number $($iteration)"
        }
        Write-EventLog @logparametersVar
        $logparametersVar = $logparameters

        Start-Sleep -Seconds 10
    }
    else {
        $logparametersVar += @{
            "EventId"   = "2"
            "Entrytype" = "Information"
            "Message"   = "Agent status: OK"
        }
        Write-EventLog @logparametersVar
        $logparametersVar = $logparameters
        Write-Host "Agent status: OK"
        break OuterLoop  # Exit both loops if agent status is OK
    }

    $iteration++
}
'@

#Get all Azure VMs which are in running state and are running Windows
$myAzureVMs = Get-AzVM -status | Where-Object { $_.PowerState -eq "VM running" -and $_.StorageProfile.OSDisk.OSType -eq "Windows" }
Write-Output "The following VMs are running and are running Windows:" 
Write-Output $myAzureVMs.Name 

#Run the script against all the listed VMs
Write-Output "Run Script Against Machines"

foreach ($vm in $myAzureVMs) {
    Write-Output "Running on $($vm.Name)"
    Invoke-AzVMRunCommand -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -CommandId 'RunPowerShellScript' -ScriptString $scriptCode
}
