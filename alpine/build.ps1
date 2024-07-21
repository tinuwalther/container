# Build container from docker file
Push-Location -Path $PSScriptRoot

$hostName      = 'alpine'
$containerName = 'alpine'
$imageName     = 'tinuwalther/alpine'
$buildDate     = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
$buildVersion  = '1.0.0'

$image     = docker images $imageName --format "{{.Repository}}"
$container = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if([string]::IsNullOrEmpty($image)){
    Write-Host "Build image $($imageName)"
    docker build --build-arg now=$buildDate --build-arg version=$buildVersion -f ./alpine.dockerfile -t $imageName .
}

if([string]::IsNullOrEmpty($container)){
    Write-Host "Run and start container $($containerName)"
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName -it $imageName
}else{
    $isrunning = docker ps --filter "name=$containerName" --format "{{.Names}}"
    if([String]::IsNullOrEmpty($isrunning)){
        Write-Host "Start container $($containerName)"
        docker start $containerName
    }
    <#
    docker exec -it $containerName pwsh --nologo
    docker exec -it $containerName /bin/bash
    #>
}


<#
docker stop $containerName

docker rm $containerName

docker rmi $imageName
#>
