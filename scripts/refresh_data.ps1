Set-Location pharma_project
dbt build
Set-Location ..
python scripts/export_marts.py
Write-Host "Donnees rafraichies. Pense a cliquer sur 'Actualiser' dans Power BI."