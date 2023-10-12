<#
.Synopsis
A function used to export all NSGs rules in all your Azure Subscriptions

.DESCRIPTION
# PowerShell function perform NSG Review

.Notes
Created   : 02-September-2022
Updated   : 02-September-2022
Version   : 1
Disclaimer: This script is provided "AS IS" with no warranties.
#>
Function Get-AzNSG-Review {
    [cmdletbinding()]
    Param (
        [switch]$All, [switch]$SelectSub, [string]$Output
    )
    # End of Parameters

    Process {
        if ($All) {
            Clear-Host
            "-All selected to export all NSG's to review all subscriptions you can access"
            $azSubs = Get-AzSubscription
            foreach ( $azSub in $azSubs ) {
                Set-AzContext -Subscription $azSub | Out-Null
                $azSubName = $azSub.Name
                $azNsgs = Get-AzNetworkSecurityGroup   
                
                # Export custom rules
                Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
                    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
                @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
                @{label = 'Rule Name'; expression = { $_.Name } }, `
                @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
                @{label = 'Source Application Security Group'; expression = { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } },
                @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
                @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
                @{label = 'Destination Application Security Group'; expression = { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } }, `
                @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
                @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
                    Export-Csv -Path "$($home)\$azSubName-nsg-rules.csv" -NoTypeInformation -Append -force
    
                # Export default rules
                Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg -Defaultrules | `
                    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
                @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
                @{label = 'Rule Name'; expression = { $_.Name } }, `
                @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
                @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
                @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
                @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
                @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
                    Export-Csv -Path "$($home)\$azSubName-nsg-rules.csv" -NoTypeInformation -Append -force            
            } # End of If
        }
        if ($SelectSub) {
            Clear-Host
            "-SelectSub selected to export a particular sub's NSG's to. Please make a selection from the below list of subs..."
            Write-Host = Get-AzSubscription
            $sub = Read-Host "Please enter Target Sub ID:"
            Write-Host = $sub
            Set-AzContext -Subscription $Sub | Out-Null
            $azSubName = $sub.Name
            $azNsgs = Get-AzNetworkSecurityGroup   
            foreach ( $azSub in $azSubs ) {
                Set-AzContext -Subscription $azSub | Out-Null
                $azSubName = $azSub.Name
                $azNsgs = Get-AzNetworkSecurityGroup   
                
                # Export custom rules
                Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg | `
                    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
                @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
                @{label = 'Rule Name'; expression = { $_.Name } }, `
                @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
                @{label = 'Source Application Security Group'; expression = { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } },
                @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
                @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
                @{label = 'Destination Application Security Group'; expression = { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } }, `
                @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
                @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
                    Export-Csv -Path "$($home)\$azSubName-nsg-rules.csv" -NoTypeInformation -Append -force
    
                # Export default rules
                Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azNsg -Defaultrules | `
                    Select-Object @{label = 'NSG Name'; expression = { $azNsg.Name } }, `
                @{label = 'NSG Location'; expression = { $azNsg.Location } }, `
                @{label = 'Rule Name'; expression = { $_.Name } }, `
                @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
                @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
                @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
                @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
                @{label = 'Resource Group Name'; expression = { $azNsg.ResourceGroupName } } | `
                    Export-Csv -Path "$($home)\$azSubName-nsg-rules.csv" -NoTypeInformation -Append -force            
            } # End of If                    
            
            Else {
                Write-Error "error occurred"
            } # End of Else.
        } # End of If
    } # End of Process
} # End of Function
