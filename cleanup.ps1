# Cleanup

$containerName = 'nexus', 'alma'
$imageName     = 'tinuwalther/alma', 'sonatype/nexus3'

docker ps

#region Stop container
$runningContainer = docker ps --format "{{.Names}}"
$runningContainer  | ForEach-Object { 
    if($containerName -contains $PSItem){
        Write-Host "Stop container $($PSItem)"
        docker stop $PSItem
    }
}
#endregion

#region Remove container
$ret = Read-Host "Would you remove the containers $($containerName)? [Y] Yes, [N] No"
if($ret -match '^y'){
    Write-Host "Remove containers $($containerName)"
    $containerName | ForEach-Object { docker rm $PSItem }
}elseif($ret -match '^n'){
    Write-Host "No"
    docker ps -a
}
#endregion

#region Remove image
$runningImage = docker images --format "{{.Repository}}"
$runningImage  | ForEach-Object { 
    if($imageName -contains $PSItem){
        $ret = Read-Host "Would you remove the image $($PSItem)? [Y] Yes, [N] No"
        if($ret -match '^y'){
            Write-Host "Remove image $($PSItem)"
            # docker rmi "$($PSItem):latest"
        }
    }
}
#endregion
