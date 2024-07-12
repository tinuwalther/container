# Cleanup

$containerName = 'nexus', 'alma'

docker ps

$runningContainer = docker ps --format "{{.Names}}"

$runningContainer  | ForEach-Object { 
    if($containerName -contains $PSItem){
        Write-Host "Stop container $($PSItem)"
        docker stop $PSItem
    }
}

$ret = Read-Host "Would you remove the containers $($containerName)? [Y] Yes, [N] No"
if($ret -match '^y'){
    Write-Host "Remove containers $($containerName)"
    $containerName | ForEach-Object { docker rm $PSItem }
}elseif($ret -match '^n'){
    Write-Host "No"
    docker ps -a
}

docker images
# Remove images
# $containerName | ForEach-Object { docker rmi "$($PSItem):latest" }