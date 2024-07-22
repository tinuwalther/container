# Build container from docker file to push to my repos
Push-Location -Path $PSScriptRoot

$networkName   = 'custom'
$network   = docker network ls --filter "name=$networkName" --format "{{.Name}}"

if([string]::IsNullOrEmpty($network)){
    Write-Host "Create network $($networkName)"
    docker network create $networkName
}
docker network inspect $networkName --format='{{json .IPAM.Config }}' | ConvertFrom-Json | Format-List

$rootImage  = 'tinuwalther'
$collection = 'alma', 'alpine'
$collection | Foreach-Object -ThrottleLimit 5 -Parallel {
    #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
    $containerName = $PSItem
    $imageName     = "$($USING:rootImage)/$($containerName)"
    $image         = docker images $imageName --format "{{.Repository}}"

    if([string]::IsNullOrEmpty($image)){
        Write-Host "Build image $($imageName)."
        docker build --build-arg now=$buildDate --build-arg version=$buildVersion -f ./$containerName.dockerfile -t $imageName .
    }else{
        Write-Host "Image $($imageName) already exists."
    }
}

<#
$containerName = 'alpine'
$containerName = 'alma'

$hostName      = $containerName 
$container     = docker ps -a --filter "name=$containerName" --format "{{.Names}}"

if([string]::IsNullOrEmpty($container)){
    Write-Host "Run and start container $($containerName)"
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName --network custom -it $imageName
    docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName -it $imageName
}else{
    $isrunning = docker ps --filter "name=$containerName" --format "{{.Names}}"
    if([String]::IsNullOrEmpty($isrunning)){
        Write-Host "Start container $($containerName)"
        docker start $containerName
    }
    docker exec -it $containerName pwsh --nologo
}
docker inspect --format='{{json .NetworkSettings.Networks.custom }}' $containerName | ConvertFrom-Json
 #>