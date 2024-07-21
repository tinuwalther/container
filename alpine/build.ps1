$hostName      = 'alpine'
$containerName = 'alpine'
$imageName     = 'tinuwalther/alpine'
$buildDate     = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
$buildVersion  = '1.0.0'

docker build --build-arg now=$buildDate --build-arg version=$buildVersion -f ./alpine.dockerfile -t $imageName .

docker run -e TZ="Europe/Zurich" --hostname $hostName --name $containerName -it $imageName pwsh --nologo

docker stop $containerName

docker rm $containerName

docker rmi $imageName
