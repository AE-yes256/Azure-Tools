Import-Module -Name ImportExcel
$counter = 0
$azSubs = Get-AzSubscription
foreach ( $azSub in $azSubs ) {
$counter++
Write-Progress -Activity "Gathering Ips's for "$azSub.Name"" -CurrentOperation $azSub -PercentComplete (($counter / $azSubs.count) * 100)
Set-AzContext -Subscription $azSub | Out-Null
$azSubName = $azSub.Name
$azNewSubName = $azSubName -replace '(\W)', '_'
Get-AzPublicIpAddress | `
                    Select-Object @{label = 'NSG Name'; expression = { $azIp.Name } }, `
                    @{label = 'Name'; expression = { $_.Name } }, `
                    @{label = 'ResourceGroupName'; expression = { $_.ResourceGroupName } }, `
                    @{label = 'Location'; expression = { $_.Location } }, `
                    @{label = 'ProvisioningState'; expression = { $_.ProvisioningState } }, `
                    @{label = 'IpAddress'; expression = { $_.IpAddress } }, `
                    @{label = 'PublicIpAllocationMethod'; expression = { $_.PublicIpAllocationMethod } }, `
                    @{label = 'Sub'; expression = { $azNewSubName } }
                    | Export-Excel -Path "$($home)\IPs.xlsx"  -AutoSize -TableName IAM -Append
}


Export-Excel -Path "$($home)\$azNewSubName-nsg-rules.xlsx"  -AutoSize -TableName nsgs -Append 
Get-AzPublicIpAddress | Select-Object DisplayName,SignInName,RoleDefinitionName,Scope | Export-Excel -Path "$($home)\IPs.xlsx"  -AutoSize -TableName IAM -Append


Get-AzPublicIpAddress | `
                    Select-Object @{label = 'NSG Name'; expression = { $azIp.Name } }, `
                    @{label = 'Name'; expression = { $_.Name } }, `
                    @{label = 'ResourceGroupName'; expression = { $_.ResourceGroupName } }, `
                    @{label = 'Location'; expression = { $_.Location } }, `
                    @{label = 'ProvisioningState'; expression = { $_.ProvisioningState } }, `
                    @{label = 'IpAddress'; expression = { $_.IpAddress } }, `
                    @{label = 'PublicIpAllocationMethod'; expression = { $_.PublicIpAllocationMethod } }, `
                    @{label = 'Sub'; expression = { $azNewSubName } }, `

                    Export-Excel -Path "$($home)\$azNewSubName-nsg-rules.xlsx"  -AutoSize -TableName nsgs -Append 
