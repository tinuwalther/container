# Testing Commands

#region PowerShellGet
Get-PSRepository
Get-Module -ListAvailable -Name PowerShellGet | Select-Object Version,Name

$RemoteRepoCreds = Get-Credential
$PSModulesUri    = 'http://nexus:8081/repository/PSModules/'
$NexusRepository = 'nexusGallery'
$Splatting = @{
    Name                      = $NexusRepository;
    SourceLocation            = $PSModulesUri;
    PublishLocation           = $PSModulesUri;
    InstallationPolicy        = 'Trusted';
    PackageManagementProvider = 'NuGet';
    Credential                = $RemoteRepoCreds;
}
Register-PSRepository @Splatting -Verbose

$File = Get-ChildItem -Path / -Filter PSRepositories.xml -Recurse -ErrorAction SilentlyContinue -Force; $File
[xml]$xml = Get-Content $File.FullName
$xml.Objs.Obj.DCT.En.Obj.MS.S

Find-Module -Name PsNetTools -Repository nexusGallery -Credential $RemoteRepoCreds -Debug
#endregion

#region PSResourceGet
Find-Module -Repository PSGallery -Name Microsoft.PowerShell.PSResourceGet -Verbose
Install-Module -Repository PSGallery -Name Microsoft.PowerShell.PSResourceGet -Force -Verbose

Get-PSResourceRepository
Get-Module -ListAvailable -Name Microsoft.PowerShell.PSResourceGet | Select-Object Version,Name

$PSModulesUri    = 'http://nexus:8081/repository/PSModules/'
$NexusRepository = 'nexusGallery'
$Splatting = @{
  Name       = $NexusRepository
  Uri        = $PSModulesUri 
  Trusted    = $true
  PassThru   = $true
  Priority   = 20 # default is 50
  APIVersion = 'v2'
}
Register-PSResourceRepository @Splatting -Verbose

Get-PSResourceRepository

$File = Get-ChildItem -Path / -Filter PSResourceRepository.xml -Recurse -ErrorAction SilentlyContinue -Force; $File

[xml]$xml = Get-Content $File.FullName
$xml.configuration.Repository

Find-PSResource -Name PsNetTools -Repository $NexusRepository -Verbose

Install-PSResource -Name PsNetTools -Scope AllUsers -PassThru -Debug
#endregion

#region Invoke-WebRequest
$RemoteRepoCreds  = Get-Credential
$RemoteRepository = 'http://nexus:8081/repository/PSModules' # https://www.powershellgallery.com/api/v2
$PackageName      = 'PsNetTools'

$Properties = @{
  Uri        = "$($RemoteRepository)/FindPackagesById()?id='$($PackageName)'"
  Credential = $RemoteRepoCreds
}
$Response = Invoke-WebRequest @Properties -AllowUnencryptedAuthentication -Verbose
[xml]$xml = $Response.Content

$PackageName      = $xml.feed.entry.properties.Title
$PackageVersion   = $xml.feed.entry.properties.Version
$LocalPackagePath = '/tmp/nupkg'
$LocalRepoName    = 'LocalPackages'
if(-not(Test-Path $LocalPackagePath)){New-Item -Path $LocalPackagePath -ItemType Directory -Force}

$Properties = @{
  Uri        = "$($RemoteRepository)/$($PackageName)/$($PackageVersion)"
  OutFile    = "$($LocalPackagePath)/$($PackageName).nupkg"
  Credential = $RemoteRepoCreds
  PassThru   = $true
}
Invoke-WebRequest @Properties -AllowUnencryptedAuthentication -Verbose
Get-ChildItem $LocalPackagePath

$Properties = @{
    Name               = $LocalRepoName
    SourceLocation     = $LocalPackagePath
    InstallationPolicy = 'Trusted'
}
Register-PSRepository @Properties -Verbose

$Properties = @{
    Name       = $PackageName
    Repository = $LocalRepoName
    Scope      = 'AllUsers'
    Force      = $true
}
Install-Module @Properties -Verbose

Unregister-PSRepository -Name $LocalRepoName
Remove-Item $LocalPackagePath -Recurse -Force
#endregion
