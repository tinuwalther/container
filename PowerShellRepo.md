<!-- TOC -->

- [Nexus container](#nexus-container)
    - [Nuget Repository](#nuget-repository)
- [Almalinux container](#almalinux-container)
    - [PowerShellGet](#powershellget)
        - [Register local Nexus Repository](#register-local-nexus-repository)
        - [Find a Module](#find-a-module)
        - [Register local Nexus Repository with credentials](#register-local-nexus-repository-with-credentials)
        - [Find a Module with credentials](#find-a-module-with-credentials)
    - [PSResourceGet](#psresourceget)

<!-- /TOC -->

# Nexus container

The Nexus container has a custom network configured.

## Nuget Repository

The Nexus Repository has a Nuget Repo for [Modules](http://nexus:8081/repository/PSModules/) and one for [Scripts](http://nexus:8081/repository/PSScripts/) configured.

PsNetTools is published at the PSModules Repository.

# Almalinux container

The almalinux has powershell installed and has the same custom network as Nexus configured.

## PowerShellGet

````powershell
Name                      InstallationPolicy   SourceLocation
----                      ------------------   --------------
PSGallery                 Untrusted            https://www.powershellgallery.com/api/v2
````

### Register local Nexus Repository

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
Find-Module -Repository nexusGallery -Verbose
````

Output:

````powershell
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

### Register local Nexus Repository with credentials

The Nexus Repository has a Nuget Repo for Modules and one for Scripts configured. Anonymous Access is disabled.

````powershell
$PSModulesUri = 'http://nexus:8081/repository/PSModules/'
$Creds        = Get-Credential
$Splatting = @{
    Name                      = 'nexusGallery';
    SourceLocation            = $PSModulesUri;
    PublishLocation           = $PSModulesUri;
    InstallationPolicy        = 'Trusted';
    PackageManagementProvider = 'NuGet';
    Credential                = $creds;
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
Find-Module -Repository nexusGallery -Credential $Creds -Verbose
````

Output:

````powershell
````

## PSResourceGet

````powershell
Get-PSResourceRepository
Name      Uri                                      Trusted Priority
----      ---                                      ------- --------
PSGallery https://www.powershellgallery.com/api/v2 False   50
````
