# Build container from docker file
Push-Location -Path $PSScriptRoot

if(-not(Test-Path "$($PSScriptRoot)/PodePSHTML")){
    git clone https://github.com/tinuwalther/PodePSHTML.git ./podepshtml
    Remove-Item ./podepshtml/.git -Recurse -Force
    Remove-Item ./podepshtml/public/img -Recurse -Force
}

$hostName      = 'podepshtml'
$containerName = 'podepshtml'
$imageName     = 'tinuwalther/pode'
$networkName   = 'custom'
$buildDate     = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
$buildVersion  = '1.0.1'

$network   = docker network ls --filter "name=$networkName" --format "{{.Name}}"
$image     = docker images $imageName --format "{{.Repository}}"
$container = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if([string]::IsNullOrEmpty($network)){
    Write-Host "Create network $($networkName)"
    docker network create $networkName
}
docker network inspect $networkName --format='{{json .IPAM.Config }}' | ConvertFrom-Json | Format-List

if([string]::IsNullOrEmpty($image)){
    Write-Host "Build image $($imageName)"
    docker build --build-arg now=$buildDate --build-arg version=$buildVersion -f ./dockerfile -t $imageName .
}

if([string]::IsNullOrEmpty($container)){
    Write-Host "Run and start container $($containerName)"
    # docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName --network $networkName -p 8080:8080 -d $imageName
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName -p 8080:8080 -d $imageName
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

docker inspect --format='{{json .NetworkSettings.Networks.custom }}' $containerName | ConvertFrom-Json

<#
Build image tinuwalther/pode
[+] Building 68.8s (29/29) FINISHED
[+] Building 56.1s (24/24) FINISHED

docker stop podepshtml; docker rm podepshtml; docker rmi tinuwalther/pode

Invoke-WebRequest -Uri 'http://localhost:8080/'

Invoke-WebRequest -Uri http://localhost:8080/api/index -Method Post

Invoke-WebRequest -Uri http://localhost:8080/api/pode -Method Post

Invoke-WebRequest -Uri http://localhost:8080/api/asset -Method Post

$SqlQuery = 'SELECT HostName, Version, vCenterServer, Cluster, ConnectionState, Created, Manufacturer, Model, PhysicalLocation FROM "classic_ESXiHosts" Limit 7'
Invoke-WebRequest -Uri http://localhost:8080/api/sqlite -Method Post -Body $SqlQuery

Invoke-WebRequest -Uri http://localhost:8080/api/pester -Method Post

Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post
#>
