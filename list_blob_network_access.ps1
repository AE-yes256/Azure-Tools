$counter = 0
$azSubs = Get-AzSubscription
foreach ( $azSub in $azSubs ) {
    $counter++
    Write-Progress -Activity "Gathering Blob access rules for "$azSub.Name"" -CurrentOperation $azSub -PercentComplete (($counter / $azSubs.count) * 100)
    Set-AzContext -Subscription $azSub | Out-Null
    $azSubName = $azSub.Name
    $azNewSubName = $azSubName -replace '(\W)', '_'
    $substorageaccount = Get-AzStorageAccount 
       
    foreach ( $blob in $substorageaccount ) {

        $netRuleSet = Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $blob.ResourceGroupName -AccountName $blob.StorageAccountName
        $ipRules = $netRuleSet.IpRules.IPAddressOrRange | Out-String
        $vnetRules = $netRuleSet.VirtualNetworkRules.VirtualNetworkResourceId | Out-String

        $blob | Select-Object @{label = 'Name'; expression = { $blob.StorageAccountName } }, `
        @{label = 'ResourceGroupName'; expression = { $blob.ResourceGroupName } }, `
        @{label = 'Location'; expression = { $blob.PrimaryLocation } }, `
        @{label = 'Sub'; expression = { $azNewSubName } }, `
        @{label = 'Kind'; expression = { $blob.Kind } }, `
        @{label = 'CreationTime'; expression = { $blob.CreationTime } }, `
        @{label = 'DefaultAction'; expression = { $blob.DefaultAction } }, `        @{label = 'Bypass'; expression = { $blob.Bypass } }, `
        @{label = 'HTTPSonly'; expression = { $blob.EnableHttpsTrafficOnly } }, `
        @{label = 'AllowedIP'; expression = { $ipRules } }, `
        @{label = 'AllowedVnet'; expression = { $vnetRules } }
        | Export-Excel -Path "$($home)\StorageAccountAccess.xlsx"  -AutoSize -TableName NetAccess -Append
    
    }
}
