# PodePSHTML

- [PodePSHTML](#podepshtml)
    - [Overview](#overview)
        - [Start page](#start-page)
        - [Pode page](#pode-page)
        - [Asset page](#asset-page)
        - [SQLite page](#sqlite-page)
        - [Pester page](#pester-page)
        - [Mermaid page](#mermaid-page)
    - [FileWatcher](#filewatcher)
        - [Re-build Index by FileWatcher](#re-build-index-by-filewatcher)
        - [Re-build Pode by FileWatcher](#re-build-pode-by-filewatcher)
        - [Re-build Asset by FileWatcher](#re-build-asset-by-filewatcher)
    - [API](#api)
        - [Re-build Index by API](#re-build-index-by-api)
        - [Re-build Pode by API](#re-build-pode-by-api)
        - [Re-build Asset by API](#re-build-asset-by-api)
        - [Re-build SQLite by API](#re-build-sqlite-by-api)
        - [Re-build Pester by API](#re-build-pester-by-api)
        - [Re-build Mermaid by API](#re-build-mermaid-by-api)

## Overview

This is an example for using pode and PSHTML with mySQLite and Pester v5+.

Requires pode, PSHTML, PsNetTools, Pester and mySQLite (mySQLite supports only Windows and Linux).

````powershell
Install-Module -Name Pode, PSHTML, mySQLite, PsNetTools, Pester -SkipPublisherCheck -Repository PSGallery -Force -Verbose
````

Clone the code from my repository:

````powershell
git clone https://github.com/tinuwalther/PodePSHTML.git
````

Start pode:

````powershell
pwsh ./PodePSHTML/PodeServer.ps1
````

````powershell
Press Ctrl. + C to terminate the Pode server
VERBOSE: Adding Route: [Get] /        # endpoint for the Index page
VERBOSE: Adding Route: [Get] /pode    # endpoint for the Pode page
VERBOSE: Adding Route: [Get] /update  # endpoint for the Assets page
VERBOSE: Adding Route: [Get] /sqlite  # endpoint for the SQLite page
VERBOSE: Adding Route: [Get] /pester  # endpoint for the Pester Tests page
VERBOSE: Adding Route: [Get] /mermaid # endpoint for the Mermaid Diagram page
````

Or pull the image from [docker hub](https://hub.docker.com/r/tinuwalther/pode) and run the container.

``docker pull tinuwalther/pode:latest``

``docker run -e TZ="Europe/Zurich" --hostname pshtml --name podepshtml -p 8080:8080 -d tinuwalther/pode``

Open your preffered browser and enter http://localhost:8080/ in the address - enjoy PodePSHTML!

### Start page

![PodePSHTM-Index](./public/img/PodePSHTML.png)

This is the default index page. Here you can cklick on the Buttons to visit the given page. You can re-build this page with the FileWatcher- or REST API method.

### Pode page

![PodePSHTM-Index](./public/img/Pode.png)

This page describe how you can use pode. You can re-build this page with the FileWatcher- or REST API method.

### Asset page

![PodePSHTM-Index](./public/img/Asset.png)

This page describe how you can update the assets for Bootstrap, Jquery, Chartjs and Mermaid. You can re-build this page with the FileWatcher- or REST API method.

### SQLite page

![PodePSHTM-Index](./public/img/SQLite.png)

This page display some data of a table from a local SQLite database. The database is located at ./PodePSHTML/db/psxi.db and contains the tables classic_ESXiHosts, classic_summary, cloud_ESXiHosts, and cloud_summary to create a query for. You can update this page with the FileWatcher- or REST API method.

### Pester page

![PodePSHTM-Index](./public/img/Pester0.png)![PodePSHTM-Index](./public/img/Pester1.png)![PodePSHTM-Index](./public/img/Pester2.png)![PodePSHTM-Index](./public/img/Pester3.png)

This page display the result of some Pester Tests. The Script for the PesterTests is located at ./PodePSHTML/bin/Invoke-PesterResult.Tests.You can update this page with the FileWatcher- or REST API method. ps1.

### Mermaid page

![PodePSHTM-Index](./public/img/Mermaid0.png)![PodePSHTM-Index](./public/img/Mermaid1.png)![PodePSHTM-Index](./public/img/Mermaid2.png)

This page display a Diagram of an ESXi Host Inventory from a local SQLite database. The database is located at ./PodePSHTML/db/psxi.db. It runs a query on the table classic_ESXiHosts. You can update this page with the FileWatcher- or REST API method.

[TOP](#)

## FileWatcher

![PodePSHTM-Index](./public/img/RequestByFileWatcher.png)

There is a FileWatcher registered on ./PodePSHTML/upload.

````powershell
VERBOSE: Creating FileWatcher for './PodePSHTML/upload'
VERBOSE: -> Registering event: Changed
VERBOSE: -> Registering event: Created
VERBOSE: -> Registering event: Deleted
VERBOSE: -> Registering event: Renamed
````

The FileWatcher monitors files (with an extension) in the folder. It wait for events of type Changed, Created, Deleted, and Renamed.

### Re-build Index by FileWatcher

Re-builds the Index.pode page:

````powershell
New-Item ./PodePSHTML/upload -Force -Name index.txt
````

### Re-build Pode by FileWatcher

The FileWatcher monitors for a file pode.txt of the type Created or Changed (Move-Item, New-Item).

Re-builds the Pode-Server.pode page:

````powershell
New-Item ./PodePSHTML/upload -Force -Name pode.txt
````

### Re-build Asset by FileWatcher

The FileWatcher monitors for a file asset.txt of the type Created or Changed (Move-Item, New-Item).

Re-builds the Update-Assets.pode page:

````powershell
New-Item ./PodePSHTML/upload -Force -Name asset.txt
````

[TOP](#)

## API

![PodePSHTM-Index](./public/img/RequestByApi.png)

It's also possible, to send REST API requests to pode. For each of the pages exists an endpoint.

````powershell
VERBOSE: Adding Route: [Post] /api/index   #API endpoint for the Index page
VERBOSE: Adding Route: [Post] /api/pode    #API endpoint for the Pode page
VERBOSE: Adding Route: [Post] /api/asset   #API endpoint for the Assets page
VERBOSE: Adding Route: [Post] /api/sqlite  #API endpoint for the SQLite page
VERBOSE: Adding Route: [Post] /api/pester  #API endpoint for the Pester Tests page
VERBOSE: Adding Route: [Post] /api/mermaid #API endpoint for the Mermaid Diagram page
````

### Re-build Index by API

Re-builds the Index.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/index -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
````

### Re-build Pode by API

Re-builds the Pode-Server.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/pode -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
````

### Re-build Asset by API

Re-builds the Update-Assets.pode page:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/asset -Method Post
````

````powershell
StatusCode        : 200
StatusDescription : OK
````

### Re-build SQLite by API

Re-builds the SQLite-Data.pode page with own sql query:

````powershell
$SqlQuery = 'SELECT * FROM "classic_ESXiHosts" Limit 5'
Invoke-WebRequest -Uri http://localhost:8080/api/sqlite -Method Post -Body $SqlQuery
````

````powershell
$SqlQuery = 'SELECT HostName, Version, vCenterServer, Cluster, ConnectionState, Created, Manufacturer, Model, PhysicalLocation FROM "classic_ESXiHosts" Limit 7'
Invoke-WebRequest -Uri http://localhost:8080/api/sqlite -Method Post -Body $SqlQuery
````

````powershell
StatusCode        : 200
StatusDescription : OK
````

### Re-build Pester by API

Re-builds the Pester-Result.pode pagew with own destinations to test:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/pester -Method Post -Body '["sbb.ch","admin.ch"]'
````

````powershell
StatusCode        : 200
StatusDescription : OK
````

### Re-build Mermaid by API

Re-builds the Mermaid-Diagram.pode page with own sql query:

````powershell
Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post -Body 'SELECT * FROM "cloud_ESXiHosts" ORDER BY HostName'
````

````powershell
StatusCode        : 200
StatusDescription : OK
````
