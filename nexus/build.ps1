# Build container from docker file
Push-Location -Path $PSScriptRoot

$containerName = 'nexus'
$imageName     = 'sonatype/nexus3'
$networkName   = 'custom'
$containerData = 'nexus-data'

$network   = docker network ls --filter "name=$networkName" --format "{{.Name}}"
$volume    = docker volume ls --filter "name=$containerData" --format "{{.Name}}"
$image     = docker images $imageName --format "{{.Repository}}"
$container = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if([string]::IsNullOrEmpty($network)){
    Write-Host "Create network $($networkName)"
    docker network create $networkName
}
docker network inspect $networkName --format='{{json .IPAM.Config }}' | ConvertFrom-Json | Format-List

if([string]::IsNullOrEmpty($volume)){
    Write-Host "Create volume $($volume)"
    docker volume create $containerData
}
docker volume inspect $containerData --format='{{json .Mountpoint }}' | ConvertFrom-Json | Format-List

if([string]::IsNullOrEmpty($image)){
    Write-Host "Download image $($imageName)"
    docker pull $imageName
}

if([string]::IsNullOrEmpty($container)){
    Write-Host "Run and start container $($containerName)"
    docker run -e TZ="Europe/Zurich"  -d -p 8081:8081 --name $containerName --network $networkName -it $imageName
}else{
    Write-Host "Start container $($containerName)"
    docker start $containerName
}

docker inspect --format='{{json .NetworkSettings.Networks.custom }}' $containerName | ConvertFrom-Json

<#
docker exec -it nexus /bin/bash
cd /nexus-data
cat admin.password

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/'
#>
