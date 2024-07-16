FROM badgerati/pode:latest
LABEL author="tinuwalther"
RUN echo "*** Build Image ***"
RUN apt-get clean all
RUN apt-get update
RUN apt-get install -y git
RUN mkdir /PodePSHTML
COPY ./PodePSHTML /PodePSHTML
# RUN git clone https://github.com/tinuwalther/PodePSHTML.git /usr/src/app
RUN echo "> Install PSModules"
RUN pwsh -Command "& {Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -SourceLocation https://www.powershellgallery.com/api/v2}"
RUN pwsh -Command "& {Install-Module -Name PSHTML, PsNetTools, mySQLite -Scope AllUsers -PassThru -Force}"
RUN pwsh -Command "& {Install-Module -Name Pester -Scope AllUsers -SkipPublisherCheck -PassThru -Force}"
RUN pwsh -Command "& {Get-Module -ListAvailable -Name Pode, Pester, PSHTML, PsNetTools, mySQLite}"
COPY profile.ps1 /opt/microsoft/powershell/7
RUN echo "*** Build finished ***"
EXPOSE 8080
CMD [ "pwsh", "-c", "/PodePSHTML/PodeServer.ps1" ]
