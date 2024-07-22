# PodePSHTML
# Build: docker build --build-arg now="$(date +%Y%m%d)" version="1.0.1" -f ./dockerfile -t $imageName .
FROM almalinux:9 AS install-base
ARG now
ARG version
LABEL os="almalinux"
LABEL author="@tinuwalther"
LABEL build-date=$now
LABEL name="PodePSHTML"
LABEL description="PodeServer with PowerShell 7"
LABEL summary="PodeServer based on almalinux with PowerShell 7 and Pode, PSHTML, PsNetTools, mySQLite, Pester"
LABEL run="docker run --hostname HOSTNAME --name CONTAINER -p 8080:8080 -d IMAGE"
LABEL stop="docker stop CONTAINER"
LABEL version=$version
RUN dnf clean all -y
RUN dnf update -y
RUN dnf install sudo -y

FROM install-base AS install-powershell
RUN curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/microsoft.repo
RUN dnf install --assumeyes powershell
RUN dnf install --assumeyes git
RUN rm -rf /etc/yum.repos.d/microsoft.repo
COPY ./profile.ps1 /opt/microsoft/powershell/7

FROM install-powershell AS install-psmodules
RUN pwsh -Command "& {Install-Module -Name Pode -Scope AllUsers -Force}"
RUN pwsh -Command "& {Install-Module -Name PSHTML -Scope AllUsers -Force}"
RUN pwsh -Command "& {Install-Module -Name PsNetTools -Scope AllUsers -Force}"
RUN pwsh -Command "& {Install-Module -Name mySQLite -Scope AllUsers -Force}"
RUN pwsh -Command "& {Install-Module -Name Pester -Scope AllUsers -SkipPublisherCheck -Force}"

FROM install-psmodules AS install-podepshtml
RUN mkdir -p /usr/src/podepshtml
COPY ./podepshtml /usr/src/podepshtml
EXPOSE 8080
CMD [ "pwsh", "-c", "/usr/src/podepshtml/PodeServer.ps1" ]