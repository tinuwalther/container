# Build container from docker file
Push-Location -Path $PSScriptRoot

# git clone https://github.com/tinuwalther/PodePSHTML.git ./PodePSHTML

$hostName      = 'PodePSHTML'
$containerName = 'PodePSHTML'
$imageName     = 'tinuwalther/pode'
$networkName   = 'custom'

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
    docker build -f ./dockerfile -t $imageName .
}

if([string]::IsNullOrEmpty($container)){
    Write-Host "Run and start container $($containerName)"
    # docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName --network $networkName -it $imageName
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName --network $networkName -p 8080:8080 -d $imageName
}else{
    $isrunning = docker ps --filter "name=$containerName" --format "{{.Names}}"
    if([String]::IsNullOrEmpty($isrunning)){
        Write-Host "Start container $($containerName)"
        docker start $containerName
    }
    # docker exec -it $containerName pwsh --nologo
}

docker inspect --format='{{json .NetworkSettings.Networks.custom }}' $containerName | ConvertFrom-Json

<#
Invoke-WebRequest -Uri 'http://localhost:8080/'

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/'

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/' -Credential (Get-Credential) -AllowUnencryptedAuthentication
#>
