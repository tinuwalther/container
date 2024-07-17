# PodePSHTML
# Build: docker build --build-arg now="$(date +%Y%m%d)" version="1.0.1" -f ./dockerfile -t $imageName .
FROM almalinux:9 AS install-base
ARG now
ARG version
LABEL os="almalinux:9"
LABEL author="@tinuwalther"
LABEL build-date=$now
LABEL name="alma"
LABEL description="Almalinux with PowerShell 7"
LABEL summary="Almalinux with PowerShell 7"
LABEL version=$version
RUN dnf clean all -y
RUN dnf update -y

FROM install-base AS install-powershell
RUN curl https://packages.microsoft.com/config/rhel/9/prod.repo | tee /etc/yum.repos.d/microsoft.repo
RUN dnf install --assumeyes powershell
RUN rm -rf /etc/yum.repos.d/microsoft.repo
RUN dnf clean all -y
COPY profile.ps1 /opt/microsoft/powershell/7
RUN dnf up --security
