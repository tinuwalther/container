# Table of Contents

- [Table of Contents](#table-of-contents)
- [Nexus container](#nexus-container)
    - [Nuget Repository](#nuget-repository)
- [Almalinux container](#almalinux-container)
    - [PowerShellGet](#powershellget)
       - [Register Nexus Repository with PowerShellGet](#register-nexus-repository-with-powershellget)
        - [Find a Module with PowerShellGet](#find-a-module-with-powershellget)
        - [PSRepositories.xml](#psrepositoriesxml)
        - [Register Nexus Repository with credentials](#register-nexus-repository-with-credentials)
        - [Find a Module with credentials](#find-a-module-with-credentials)
    - [PSResourceGet](#psresourceget)
        - [Register Nexus Repository with PSResourceGet](#register-nexus-repository-with-psresourceget)
        - [Find a Module with PSResourceGet](#find-a-module-with-psresourceget)
        - [PSResourceRepository.xml](#psresourcerepositoryxml)
        - [Install Module with PSResourceGet](#install-module-with-psresourceget)
    - [Offline Installation NuPkg](#offline-installation-nupkg)
        - [Find Module with Invoke-WebRequest](#find-module-with-invoke-webrequest)
        - [Download the Package with Invoke-WebRequest](#download-the-package-with-invoke-webrequest)
        - [Register a local path as local Repository](#register-a-local-path-as-local-repository)
        - [Install the Module from the local Repository](#install-the-module-from-the-local-repository)
    - [Conclusion](#conclusion)
    - [Issues PSResourceGet](#issues-psresourceget)

# Nexus container

Sonatype Nexus Repository OSS 3.70.1-02.

The Nexus container and the almalinux has a custom network configured.

## Nuget Repository

The Nexus Repository has a Nuget Repo for [Modules](http://nexus:8081/repository/PSModules/) and one for [Scripts](http://nexus:8081/repository/PSScripts/) configured.

PsNetTools is published at the PSModules Repository.

# Almalinux container

The almalinux has powershell installed and has configured the same custom network as the Nexus container.

````
Name                           Value
----                           -----
PSVersion                      7.4.3
PSEdition                      Core
GitCommitId                    7.4.3
OS                             AlmaLinux 9.4 (Seafoam Ocelot)
Platform                       Unix
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0

ModuleType Version    PreRelease Name                                PSEdition
---------- -------    ---------- ----                                ---------
Binary     1.0.5                 Microsoft.PowerShell.PSResourceGet  Core,Desk
````

## PowerShellGet

````powershell
Get-PSRepository

Name                      InstallationPolicy   SourceLocation
----                      ------------------   --------------
PSGallery                 Trusted              https://www.powershellgallery.com/api/v2
````

### Register Nexus Repository with PowerShellGet

The Nexus Repository has a Nuget Repo for Modules and one for Scripts configured. Anonymous Access is enabled.

````powershell
$PSModulesUri = 'http://nexus:8081/repository/PSModules/'
$Splatting = @{
    Name                      = 'nexusGallery';
    SourceLocation            = $PSModulesUri;
    PublishLocation           = $PSModulesUri;
    InstallationPolicy        = 'Trusted';
    PackageManagementProvider = 'NuGet';
}
Register-PSRepository @Splatting -Verbose
````

Output:

````powershell
VERBOSE: Repository details, Name = 'PSGallery', Location = 'https://www.powershellgallery.com/api/v2'; IsTrusted = 'False'; IsRegistered = 'True'.
VERBOSE: Performing the operation "Register Module Repository." on target "Module Repository 'nexusGallery' (http://nexus:8081/repository/PSModules/) in provider 'PowerShellGet'.".
VERBOSE: The specified PackageManagement provider name 'NuGet'.
VERBOSE: Successfully registered the repository 'nexusGallery' with source location 'http://nexus:8081/repository/PSModules/'.
VERBOSE: Repository details, Name = 'nexusGallery', Location = 'http://nexus:8081/repository/PSModules/'; IsTrusted = 'True'; IsRegistered = 'True'.
````

### Find a Module with PowerShellGet

````powershell
Find-Module -Name PsNetTools -Repository nexusGallery -Verbose
````

Output:

````powershell
VERBOSE: Suppressed Verbose Repository details, Name = 'nexusGallery', Location = 'http://nexus:8081/repository/PSModules/'; IsTrusted = 'True'; IsRegistered = 'True'.
VERBOSE: Repository details, Name = 'nexusGallery', Location = 'http://nexus:8081/repository/PSModules/'; IsTrusted = 'True'; IsRegistered = 'True'.
VERBOSE: Using the provider 'PowerShellGet' for searching packages.
VERBOSE: Using the specified source names : 'nexusGallery'.
VERBOSE: Getting the provider object for the PackageManagement Provider 'NuGet'.
VERBOSE: The specified Location is 'http://nexus:8081/repository/PSModules/' and PackageManagementProvider is 'NuGet'.
VERBOSE: Searching repository 'http://nexus:8081/repository/PSModules/FindPackagesById()?id='PsNetTools'' for ''.
VERBOSE: Total package yield:'1' for the specified package 'PsNetTools'.

Version              Name                                Repository           Description
-------              ----                                ----------           -----------
0.7.8                PsNetTools                          nexusGallery         Cross platform PowerShell module to test networ… 
````

### PSRepositories.xml

````powershell
$File = Get-ChildItem -Path / -Filter PSRepositories.xml -Recurse -ErrorAction SilentlyContinue -Force; $File
````

Output:

````powershell
Directory: /root/.cache/powershell/PowerShellGet

UnixMode         User Group         LastWriteTime         Size Name
--------         ---- -----         -------------         ---- ----
-rw-r--r--       root root       07/11/2024 16:34         2884 PSRepositories.xml
````

````powershell
[xml]$xml = Get-Content $File.FullName
$xml.Objs.Obj.DCT.En.Obj.MS.S

N                         #text
-                         -----
Name                      nexusGallery
SourceLocation            http://nexus:8081/repository/PSModules/
PublishLocation           http://nexus:8081/repository/PSModules/
ScriptPublishLocation     http://nexus:8081/repository/PSModules/
InstallationPolicy        Trusted
PackageManagementProvider NuGet
````

### Register Nexus Repository with credentials

The Nexus Repository has a Nuget Repo for Modules and one for Scripts configured. Anonymous Access is disabled.

````powershell
$RemoteRepoCreds = Get-Credential
$PSModulesUri    = 'http://nexus:8081/repository/PSModules/'
$Splatting = @{
    Name                      = 'nexusGallery';
    SourceLocation            = $PSModulesUri;
    PublishLocation           = $PSModulesUri;
    InstallationPolicy        = 'Trusted';
    PackageManagementProvider = 'NuGet';
    Credential                = $RemoteRepoCreds;
}
Register-PSRepository @Splatting -Verbose
````

Output:

````powershell
VERBOSE: Repository details, Name = 'PSGallery', Location = 'https://www.powershellgallery.com/api/v2'; IsTrusted = 'False'; IsRegistered = 'True'.
VERBOSE: Performing the operation "Register Module Repository." on target "Module Repository 'nexusGallery' (http://nexus:8081/repository/PSModules/) in provider 'PowerShellGet'.".
VERBOSE: The specified PackageManagement provider name 'NuGet'.
WARNING: Unable to resolve package source 'http://nexus:8081/repository/PSModules/'.
VERBOSE: Successfully registered the repository 'nexusGallery' with source location 'http://nexus:8081/repository/PSModules/'.
VERBOSE: Repository details, Name = 'nexusGallery', Location = 'http://nexus:8081/repository/PSModules/'; IsTrusted = 'True'; IsRegistered = 'True'.
````

### Find a Module with credentials

````powershell
Find-Module -Name PsNetTools -Repository nexusGallery -Credential $RemoteRepoCreds -Verbose
````

Output:

````powershell
VERBOSE: Suppressed Verbose Repository details, Name = 'nexusGallery', Location = 'http://nexus:8081/repository/PSModules/'; IsTrusted = 'True'; IsRegistered = 'True'.
VERBOSE: Repository details, Name = 'nexusGallery', Location = 'http://nexus:8081/repository/PSModules/'; IsTrusted = 'True'; IsRegistered = 'True'.
VERBOSE: Using the provider 'PowerShellGet' for searching packages.
VERBOSE: Using the specified source names : 'nexusGallery'.
VERBOSE: Getting the provider object for the PackageManagement Provider 'NuGet'.
VERBOSE: The specified Location is 'http://nexus:8081/repository/PSModules/' and PackageManagementProvider is 'NuGet'.
WARNING: Unable to resolve package source 'http://nexus:8081/repository/PSModules/'.
VERBOSE: Total package yield:'0' for the specified package 'PsNetTools'.
Find-Package: No match was found for the specified search criteria and module name 'PsNetTools'. Try Get-PSRepository to see all
available registered module repositories.
````

[Top](#table-of-contents)

## PSResourceGet

````powershell
Get-PSResourceRepository

Name      Uri                                      Trusted Priority
----      ---                                      ------- --------
PSGallery https://www.powershellgallery.com/api/v2 False   50
````

### Register Nexus Repository with PSResourceGet

The Nexus Repository has a Nuget Repo for Modules and one for Scripts configured. Anonymous Access is enabled.

````powershell
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
````

Output:

````powershell
VERBOSE: Performing the operation "Register repository to repository store" on target "nexusGallery".

Name         Uri                                     Trusted Priority
----         ---                                     ------- --------
nexusGallery http://nexus:8081/repository/PSModules/ True    20
````

### Find a Module with PSResourceGet

````powershell
Find-PSResource -Name PsNetTools -Repository $NexusRepository -Verbose
````

Output:

````powershell
Name       Version Prerelease Repository   Description
----       ------- ---------- ----------   -----------
PsNetTools 0.7.8              nexusGallery Cross platform PowerShell module to test network functions, like DNS, TCP, UDP, WebRequest, ...
````

### PSResourceRepository.xml

````powershell
$File = Get-ChildItem -Path / -Filter PSResourceRepository.xml -Recurse -ErrorAction SilentlyContinue -Force; $File
````

Output:

````powershell
    Directory: /root/.local/share/PSResourceGet

UnixMode         User Group         LastWriteTime         Size Name
--------         ---- -----         -------------         ---- ----
-rw-r--r--       root root       07/12/2024 16:17          329 PSResourceRepository.xml
````

````powershell
[xml]$xml = Get-Content $File.FullName
$xml.configuration.Repository
````

Output:

````powershell
Name       : PSGallery
Url        : https://www.powershellgallery.com/api/v2
APIVersion : v2
Priority   : 50
Trusted    : false

Name       : nexusGallery
Url        : http://nexus:8081/repository/PSModules/
APIVersion : v2
Priority   : 20
Trusted    : true
````

### Install Module with PSResourceGet

````powershell
Install-PSResource nexusGallery -Name PsNetTools -Scope AllUsers -PassThru -Debug
````

Output:

````powershell
VERBOSE: All paths to search: '/usr/local/share/powershell/Modules'

Confirm
Continue with this operation?
[Y] Yes  [A] Yes to All  [H] Halt Command  [S] Suspend  [?] Help (default is "Y"): a
VERBOSE: All paths to search: '/usr/local/share/powershell/Scripts'
VERBOSE: Retrieving directories in the path '/usr/local/share/powershell/Modules'
VERBOSE: Retrieving directories in the path '/usr/local/share/powershell/Scripts'
VERBOSE: All paths to search: '/usr/local/share/powershell/Modules/PsNetTools'
DEBUG: In GetHelper::GetPackagesFromPath()
DEBUG: In GetHelper::FilterPkgPathsByName()
DEBUG: In GetHelper::FilterPkgPathsByVersion()
DEBUG: Searching through package path: '/usr/local/share/powershell/Modules/PsNetTools'
DEBUG: Searching through package path: '/usr/local/share/powershell/Modules/PsNetTools'
DEBUG: Searching through package version path: '/usr/local/share/powershell/Modules/PsNetTools/0.7.8'
VERBOSE: Leaf directory in path '/usr/local/share/powershell/Modules/PsNetTools/0.7.8' cannot be parsed into a version.
DEBUG: In InstallPSResource::ProcessInstallHelper()
DEBUG: In InstallHelper::BeginInstallPackages()
DEBUG: Parameters passed in >>> Name: 'PsNetTools'; VersionRange: ''; NuGetVersion: ''; VersionType: 'NoVersion'; Version: ''; Prerelease: 'False'; Repository: ''; AcceptLicense: 'False'; Quiet: 'False'; Reinstall: 'False'; TrustRepository: 'False'; NoClobber: 'False'; AsNupkg: 'False'; IncludeXml 'True'; SavePackage 'False'; TemporaryPath ''; SkipDependencyCheck: 'False'; AuthenticodeCheck: 'False'; PathsToInstallPkg: '/usr/local/share/powershell/Modules,/usr/local/share/powershell/Scripts'; Scope 'AllUsers'
DEBUG: In InstallHelper::ProcessRepositories()
VERBOSE: Attempting to search for packages in 'nexusGallery'
DEBUG: In InstallHelper::InstallPackages()
DEBUG: In InstallHelper::InstallPackage()
DEBUG: In V2ServerAPICalls::FindName()
DEBUG: In V2ServerAPICalls::HttpRequestCall()
DEBUG: Request url is 'http://nexus:8081/repository/PSModules//FindPackagesById()?id='PsNetTools'&$inlinecount=allpages&$filter=IsLatestVersion and Id eq 'PsNetTools''

Confirm
Are you sure you want to perform this action?
Performing the operation "Install-PSResource" on target "Package to install: 'PsNetTools', version: '0.7.8'".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): a
DEBUG: In V2ServerAPICalls::InstallVersion()
DEBUG: In V2ServerAPICalls::HttpRequestCallForContent()
DEBUG: Request url is 'http://nexus:8081/repository/PSModules//package/PsNetTools/0.7.8'
VERBOSE: Attempting to delete '/tmp/8b3d78c6-49b8-466e-ab1b-8c9b2f978789'
VERBOSE: Successfully deleted '/tmp/8b3d78c6-49b8-466e-ab1b-8c9b2f978789'
Install-PSResource: 'Response status code does not indicate success: 404 (Not Found).' Request sent: 'http://nexus:8081/repository/PSModules//package/PsNetTools/0.7.8'
````

[Top](#table-of-contents)

## Offline Installation NuPkg

### Find Module with Invoke-WebRequest

````powershell
RemoteRepoCreds  = Get-Credential
$RemoteRepository = 'http://nexus:8081/repository/PSModules' # https://www.powershellgallery.com/api/v2
$PackageName      = 'PsNetTools'

$Properties = @{
  Uri        = "$($RemoteRepository)/FindPackagesById()?id='$($PackageName)'"
  Credential = $RemoteRepoCreds
}
$Response = Invoke-WebRequest @Properties -AllowUnencryptedAuthentication -Verbose
[xml]$xml = $Response.Content
````

### Download the Package with Invoke-WebRequest

````powershell
$RemoteRepoCreds  = Get-Credential
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
````

### Register a local path as local Repository

````powershell
$Properties = @{
  Name               = $LocalRepoName
  SourceLocation     = $LocalPackagePath
  InstallationPolicy = 'Trusted'
}
Register-PSRepository @Properties -Verbose
````

### Install the Module from the local Repository

````powershell
$Properties = @{
  Name       = $PackageName
  Repository = $LocalRepoName
  Scope      = 'AllUsers'
  Force      = $true
}
Install-Module @Properties -Verbose
````

## Conclusion

If the anonymous users to access the server is disabled, only the Invoke-WebRequest works:

````powershell
VERBOSE: Requested HTTP/1.1 GET with 0-byte payload
VERBOSE: Received HTTP/1.1 21510-byte response of content type application/zip
VERBOSE: File Name: PsNetTools.nupkg
````

[Top](#table-of-contents)

## Issues PSResourceGet

[Sonatype Nexus v2 feeds does not work #1466](https://github.com/PowerShell/PSResourceGet/issues/1466)

[Install-PSResource fails with 404 for a module that Find-PSResource was able to find #1491](https://github.com/PowerShell/PSResourceGet/issues/1491)

[Top](#table-of-contents)
