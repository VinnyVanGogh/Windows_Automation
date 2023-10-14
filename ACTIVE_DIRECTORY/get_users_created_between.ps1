Import-Module ActiveDirectory

# Start and end date in YYYY-MM-DD format
$start_date = Get-Date '2023-04-01'
$end_date = Get-Date '2023-08-23'

# Filter users created within the date range
$created_users = Get-ADUser -Filter {Created -ge $start_date -and Created -le $end_date} 

# Total number of users
$user_count = Get-ADUser -Filter * | Measure-Object | Select-Object -ExpandProperty Count

Write-Host "Total number of users: $user_count"
Write-Host "Number of users created between $start_date and $end_date - $($created_users.Count)"
