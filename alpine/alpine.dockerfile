# PodePSHTML
# Build: docker build --build-arg now="$(date +%Y%m%d)" version="1.0.1" -f ./dockerfile -t $imageName .
FROM alpine:latest AS install-base
ARG now
ARG version
LABEL os="alpine"
LABEL author="@tinuwalther"
LABEL build-date=$now
LABEL name="alpine"
LABEL description="alpinelinux with PowerShell 7"
LABEL summary="alpinelinux with PowerShell 7"
LABEL version=$version
RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    curl

RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust

RUN apk -i upgrade --no-interactive

FROM install-base AS install-powershell
RUN curl -L https://github.com/PowerShell/PowerShell/releases/download/v7.4.3/powershell-7.4.3-linux-musl-x64.tar.gz -o /tmp/powershell.tar.gz
RUN mkdir -p /opt/microsoft/powershell/7
RUN tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
RUN chmod +x /opt/microsoft/powershell/7/pwsh
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
RUN rm -rf /tmp/powershell.tar.gz
COPY profile.ps1 /opt/microsoft/powershell/7
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
