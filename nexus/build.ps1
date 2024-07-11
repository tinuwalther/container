# Build container from docker file
Push-Location -Path $PSScriptRoot

$containerName = 'nexus'
$imageName     = 'sonatype/nexus3'

$image     = docker images $imageName --format "{{.Repository}}"
$container = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if([string]::IsNullOrEmpty($image)){
    docker pull $imageName
}

if([string]::IsNullOrEmpty($container)){
    docker run -e TZ="Europe/Zurich"  -d -p 8081:8081 --name $containerName --network custom -it $imageName
}else{
    docker start $containerName
}

docker inspect --format='{{json .NetworkSettings.Networks.custom }}' $containerName | ConvertFrom-Json

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/'
