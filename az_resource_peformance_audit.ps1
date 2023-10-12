$counter = 0
$azSubs = Get-AzSubscription
foreach ( $azSub in $azSubs ) {
    $counter++
    Write-Progress -Activity "Getting Resources "$azSub.Name"" -CurrentOperation $azSub -PercentComplete (($counter / $azSubs.count) * 100)
    Set-AzContext -Subscription $azSub | Out-Null
    $azSubName = $azSub.Name
    $azNewSubName = $azSubName -replace '(\W)', '_'
    $azresources = Get-AzResource | where-object -FilterScript { $_.ResourceType -eq 'Microsoft.Compute/virtualMachines' }
    foreach ($id in $azresources) {
        $metric_CPU_AVG = Get-AzMetric -ResourceId $id.ResourceId -TimeGrain 12:00:00 -MetricName "Percentage CPU" -StartTime (Get-Date).AddDays(-30) -AggregationType Average -WarningAction silentlyContinue
        $metric_CPU_Max = Get-AzMetric -ResourceId $id.ResourceId -TimeGrain 12:00:00 -MetricName "Percentage CPU" -StartTime (Get-Date).AddDays(-30) -AggregationType Maximum -WarningAction silentlyContinue
        $metric_CPU_Max_AVG = $metric_CPU_Max.Data.Maximum | Measure-Object -Average
        $metric_CPU_AVG_AVG = $metric_CPU_AVG.Data.Average | Measure-Object -Average
        $output = New-Object PSObject -Property @{
            'ServerName' = $id.Name
            'ResourceGroupName' = $id.ResourceGroupName
            'Location' = $id.Location
            'ResourceId' = $id.ResourceId
            '30d Max CPU Average' = $metric_CPU_Max_AVG.Average
            '30d Average CPU Average' = $metric_CPU_AVG_AVG.Average
        }
        $output | Export-Excel -Path "$($home)\Azure_report.xlsx" -AutoSize -TableName Report -Append
    }
      

}
