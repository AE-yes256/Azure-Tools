Import-Module -Name ImportExcel
$counter = 0
$azSubs = Get-AzSubscription
foreach ( $azSub in $azSubs ) {
$counter++
Write-Progress -Activity "Gathering Permissions's for "$azSub.Name"" -CurrentOperation $azSub -PercentComplete (($counter / $azSubs.count) * 100)
Set-AzContext -Subscription $azSub | Out-Null
$azSubName = $azSub.Name
$azNewSubName = $azSubName -replace '(\W)', '_'
Get-AzRoleAssignment | Select-Object DisplayName,SignInName,RoleDefinitionName,Scope | Export-Excel -Path "$($home)\$azNewSubName-IAM.xlsx"  -AutoSize -TableName IAM -Append
}
