# Use a base image that supports multiple services
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    apt-transport-https \
    gnupg \
    ca-certificates \
    wget \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Prowlarr
RUN mkdir /prowlarr && \
    curl -L https://github.com/prowlarr/prowlarr/releases/download/v0.7.2.1530/prowlarr.deb -o /prowlarr/prowlarr.deb && \
    dpkg -i /prowlarr/prowlarr.deb && \
    apt-get install -f

# Install Radarr
RUN mkdir /radarr && \
    curl -L https://github.com/Radarr/Radarr/releases/download/v3.0.2.4640/Radarr.master.3.0.2.4640.linux-core-x64.tar.gz -o /radarr/radarr.tar.gz && \
    tar -xzf /radarr/radarr.tar.gz -C /radarr && \
    ln -s /radarr/Radarr /usr/bin/radarr

# Install Sonarr
RUN mkdir /sonarr && \
    curl -L https://github.com/Sonarr/Sonarr/releases/download/v3.0.7.1501/Sonarr.master.3.0.7.1501.linux-core-x64.tar.gz -o /sonarr/sonarr.tar.gz && \
    tar -xzf /sonarr/sonarr.tar.gz -C /sonarr && \
    ln -s /sonarr/Sonarr /usr/bin/sonarr

# Install qBittorrent
RUN mkdir /qbittorrent && \
    curl -L https://github.com/qbittorrent/qBittorrent/releases/download/release-4.4.0/qbittorrent_4.4.0_amd64.deb -o /qbittorrent/qbittorrent.deb && \
    dpkg -i /qbittorrent/qbittorrent.deb && \
    apt-get install -f

# Set up service ports
EXPOSE 9696 7878 8989 8080 6881

# Start all services
CMD ["/bin/bash", "-c", "service prowlarr start && service radarr start && service sonarr start && qbittorrent-nox"]
