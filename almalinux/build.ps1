# Build container from docker file
Push-Location -Path $PSScriptRoot

$hostName      = 'alma'
$containerName = 'alma'
$imageName     = 'tinuwalther/alma'
$networkName   = 'custom'

$network   = docker network ls --filter "name=$networkName" --format "{{.Name}}"
$image     = docker images $imageName --format "{{.Repository}}"
$container = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

# if([string]::IsNullOrEmpty($network)){
#     Write-Host "Create network $($networkName)"
#     docker network create $networkName
# }
# docker network inspect $networkName --format='{{json .IPAM.Config }}' | ConvertFrom-Json | Format-List

if([string]::IsNullOrEmpty($image)){
    Write-Host "Build image $($imageName)"
    docker build -f ./alma.dockerfile -t $imageName .
}

if([string]::IsNullOrEmpty($container)){
    Write-Host "Run and start container $($containerName)"
    # docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName --network custom -it $imageName
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName -it $imageName
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
$PSVersionTable

Get-Module -ListAvailable *PSResourceGet

Invoke-WebRequest -Uri 'http://nexus:8081/'

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/'

Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/' -Credential (Get-Credential) -AllowUnencryptedAuthentication
#>
