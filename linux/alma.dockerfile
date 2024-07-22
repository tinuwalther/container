FROM almalinux:9 AS install-base
ARG now
ARG version
LABEL os="alma"
LABEL author="@tinuwalther"
LABEL build-date=$now
LABEL name="alma"
LABEL description="almalinux with PowerShell 7 and git"
LABEL summary="almalinux with PowerShell 7"
LABEL version=$version
RUN dnf clean all -y
RUN dnf update -y
RUN dnf install sudo -y

FROM install-base AS install-powershell
RUN curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/microsoft.repo
RUN dnf install --assumeyes powershell
RUN dnf install --assumeyes git
RUN rm -rf /etc/yum.repos.d/microsoft.repo
COPY alma/profile.ps1 /opt/microsoft/powershell/7
CMD [ "pwsh" ]

# FROM install-powershell AS install-psmodules
# RUN pwsh -Command "& {Install-Module -Name Pode -Scope AllUsers -Force}"
# RUN pwsh -Command "& {Install-Module -Name PSHTML -Scope AllUsers -Force}"
# RUN pwsh -Command "& {Install-Module -Name PsNetTools -Scope AllUsers -Force}"
# RUN pwsh -Command "& {Install-Module -Name mySQLite -Scope AllUsers -Force}"
# RUN pwsh -Command "& {Install-Module -Name Pester -Scope AllUsers -SkipPublisherCheck -Force}"

# FROM install-psmodules AS install-podepshtml
# RUN mkdir /usr/src/podepshtml
# COPY ./pode/podepshtml /usr/src/podepshtml
# RUN git clone https://github.com/tinuwalther/PodePSHTML.git /usr/src/podepshtml
# EXPOSE 8080
# CMD [ "pwsh", "-c", "/usr/src/podepshtml/PodeServer.ps1" ]
