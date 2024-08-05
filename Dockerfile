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
    curl -o servarr-install-script.sh https://raw.githubusercontent.com/Servarr/Wiki/master/servarr/servarr-install-script.sh && \
    yes "2" | sudo bash servarr-install-script.sh | yes "" | yes "yes"

# Install Radarr

# Install Sonarr

# Install qBittorrent

# Set up service ports
EXPOSE 9696 7878 8989 8080 6881

# Start all services
CMD ["/bin/bash", "-c", "service prowlarr start && service radarr start && service sonarr start && qbittorrent-nox"]
