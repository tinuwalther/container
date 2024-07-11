# Build container from docker file
Push-Location -Path $PSScriptRoot

$hostName      = 'alma'
$containerName = 'alma'
$imageName     = 'tinuwalther/alma'

$image     = docker images $imageName --format "{{.Repository}}"
$container = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if([string]::IsNullOrEmpty($image)){
    docker build -f ./dockerfile -t $imageName .
}

if([string]::IsNullOrEmpty($container)){
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName --network custom -it $imageName
}else{
    docker exec -it $containerName pwsh --nologo
}

<#
docker inspect --format='{{json .NetworkSettings.Networks.custom }}' $containerName | ConvertFrom-Json

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/'
#>
