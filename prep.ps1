# Start Docker if it's not running
Push-Location -Path $PSScriptRoot
$isrunning = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
if([String]::IsNullOrEmpty($isrunning)){
    Write-Host "Start docker, please wait..." -ForegroundColor Cyan
    Start-Process -FilePath "$($env:ProgramFiles)\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
}else{
    Write-Host "Docker is already running" -ForegroundColor Green
}
