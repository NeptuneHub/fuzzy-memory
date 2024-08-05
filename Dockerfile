# Use a base image that supports multiple services
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    libchromaprint-tools \
    mediainfo \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install .NET Core runtime required for these services
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    gnupg \
    ca-certificates \
    && curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl -sSL https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install -y dotnet-runtime-6.0 \
    && rm -rf /var/lib/apt/lists/*

# Install Prowlarr
RUN groupadd -r prowlarr && useradd -r -g prowlarr prowlarr
RUN mkdir -p /opt/Prowlarr /var/lib/prowlarr
RUN ARCH=$(dpkg --print-architecture) && \
    DLURL="https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}" && \
    curl -L -o /tmp/prowlarr.tar.gz $DLURL && \
    tar -xzf /tmp/prowlarr.tar.gz -C /opt/Prowlarr --strip-components=1 && \
    rm /tmp/prowlarr.tar.gz
RUN chown -R prowlarr:prowlarr /opt/Prowlarr /var/lib/prowlarr

# Install Radarr
RUN groupadd -r radarr && useradd -r -g radarr radarr
RUN mkdir -p /opt/Radarr /var/lib/radarr
RUN ARCH=$(dpkg --print-architecture) && \
    DLURL="https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}" && \
    curl -L -o /tmp/radarr.tar.gz $DLURL && \
    tar -xzf /tmp/radarr.tar.gz -C /opt/Radarr --strip-components=1 && \
    rm /tmp/radarr.tar.gz
RUN chown -R radarr:radarr /opt/Radarr /var/lib/radarr

# Install Sonarr
RUN wget -qO- https://raw.githubusercontent.com/Sonarr/Sonarr/develop/distribution/debian/install.sh | bash
#RUN groupadd -r sonarr && useradd -r -g sonarr sonarr
#RUN mkdir -p /opt/Sonarr /var/lib/sonarr
#RUN ARCH=$(dpkg --print-architecture) && \
#    DLURL="https://sonarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}" && \
#    curl -L -o /tmp/sonarr.tar.gz $DLURL && \
#    tar -xzf /tmp/sonarr.tar.gz -C /opt/Sonarr --strip-components=1 && \
#    rm /tmp/sonarr.tar.gz
#RUN chown -R sonarr:sonarr /opt/Sonarr /var/lib/sonarr

# Install Jackett
RUN groupadd -r jackett && useradd -r -g jackett jackett
RUN mkdir -p /opt/Jackett /var/lib/jackett
RUN ARCH=$(dpkg --print-architecture) && \
    DLURL="https://github.com/Jackett/Jackett/releases/latest/download/Jackett.Binaries.Linux${ARCH}.tar.gz" && \
    echo "Downloading Jackett from $DLURL" && \
    wget -q -O /tmp/jackett.tar.gz $DLURL && \
    echo "Extracting Jackett" && \
    tar -xzf /tmp/jackett.tar.gz -C /opt/Jackett --strip-components=1 && \
    rm /tmp/jackett.tar.gz
RUN chown -R jackett:jackett /opt/Jackett /var/lib/jackett

# Install qBittorrent
RUN apt-get update && apt-get install -y \
    qbittorrent-nox \
    && rm -rf /var/lib/apt/lists/*

# Expose necessary ports for all services
EXPOSE 9696 7878 8989 9117 8080

# Create a script to run all services
RUN echo '#!/bin/bash\n\
/opt/Prowlarr/Prowlarr -nobrowser -data=/var/lib/prowlarr &\n\
/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr &\n\
/opt/Sonarr/Sonarr -nobrowser -data=/var/lib/sonarr &\n\
/opt/Jackett/Jackett -d /var/lib/jackett &\n\
qbittorrent-nox &\n\
wait' > /usr/local/bin/start-services.sh && chmod +x /usr/local/bin/start-services.sh

# Switch to root user to start all services
USER root

# Command to run all services
CMD ["/usr/local/bin/start-services.sh"]
