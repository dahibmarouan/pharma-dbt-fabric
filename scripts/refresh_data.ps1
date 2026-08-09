Set-Location pharma_project
dbt build

if ($LASTEXITCODE -ne 0) {
    Write-Host "dbt build FAILED - export cancelled, no data was updated." -ForegroundColor Red
    Set-Location ..
    exit 1
}

Set-Location ..
python scripts/export_marts.py
Write-Host "Data refreshed successfully. Remember to click 'Refresh' in Power BI." -ForegroundColor Green