FROM almalinux:9 AS install-base
ARG now
ARG version
LABEL os="alma"
LABEL author="@tinuwalther"
LABEL build-date=$now
LABEL name="alma"
LABEL description="almalinux with PowerShell 7"
LABEL summary="almalinux with PowerShell 7"
LABEL version=$version
RUN dnf clean all -y
RUN dnf update -y
RUN dnf install sudo -y

FROM install-base AS install-powershell
RUN curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/microsoft.repo
RUN dnf install --assumeyes powershell
RUN dnf install --assumeyes git
COPY profile.ps1 /opt/microsoft/powershell/7
CMD [ "pwsh" ]
