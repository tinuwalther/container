# Table of Contents

<!-- TOC -->autoauto- [Table of Contents](#table-of-contents)auto- [Nexus container](#nexus-container)auto    - [Nuget Repository](#nuget-repository)auto- [Almalinux container](#almalinux-container)auto    - [PowerShellGet](#powershellget)auto        - [Register Nexus Repository](#register-nexus-repository)auto        - [Find a Module](#find-a-module)auto        - [PSRepositories.xml](#psrepositoriesxml)auto        - [Register Nexus Repository with credentials](#register-nexus-repository-with-credentials)auto        - [Find a Module with credentials](#find-a-module-with-credentials)auto    - [PSResourceGet](#psresourceget)auto    - [Offline Installation NuPkg](#offline-installation-nupkg)auto    - [Conclusion](#conclusion)auto    - [Issues](#issues)autoauto<!-- /TOC -->

# Nexus container

Sonatype Nexus Repository OSS 3.70.1-02
The Nexus container has a custom network configured.

## Nuget Repository

The Nexus Repository has a Nuget Repo for [Modules](http://nexus:8081/repository/PSModules/) and one for [Scripts](http://nexus:8081/repository/PSScripts/) configured.

PsNetTools is published at the PSModules Repository.

# Almalinux container

The almalinux has powershell installed and has the same custom network as Nexus configured.

## PowerShellGet

````powershell
Get-PSRepository

Name                      InstallationPolicy   SourceLocation
----                      ------------------   --------------
PSGallery                 Untrusted            https://www.powershellgallery.com/api/v2
````

### Register Nexus Repository

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

### Find a Module

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
$File = Get-ChildItem -Path / -Filter PSRepositories.xml -Recurse -ErrorAction SilentlyContinue -Force
$File
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

[Top](#table-of-contents)

## Offline Installation NuPkg

Download the Package:

````powershell
Invoke-WebRequest -Uri 'http://nexus:8081/repository/PSModules/PsNetTools/0.7.8' -OutFile '/tmp/nupkg/PsNetTools.nupkg'
````

Register a local path as local Repository:

````powershell
Register-PSRepository -Name LocalPackages -SourceLocation /tmp/nupkg/ -InstallationPolicy Trusted
````

Install the Module from the local Repository:

````powershell
Install-Module PsNetTools -Scope AllUsers -Repository LocalPackages -Force
````

or

````powershell
Install-Package PsNetTools -Source nexusGallery
````

## Conclusion

If the anonymous users to access the server is disabled, only the Invoke-WebRequest works:

VERBOSE: Requested HTTP/1.1 GET with 0-byte payload
VERBOSE: Received HTTP/1.1 21510-byte response of content type application/zip
VERBOSE: File Name: PsNetTools.nupkg

[Top](#table-of-contents)

## Issues PSResourceGet

[Sonatype Nexus v2 feeds does not work #1466](https://github.com/PowerShell/PSResourceGet/issues/1466)

[Install-PSResource fails with 404 for a module that Find-PSResource was able to find #1491](https://github.com/PowerShell/PSResourceGet/issues/1491)

[Top](#table-of-contents)
