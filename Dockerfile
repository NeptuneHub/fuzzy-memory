# Use a base image that supports multiple services
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update

# Install Prowlarr
# Install necessary packages
RUN apt-get install -y \
    curl \
    sqlite3 \
    libchromaprint-tools \
    mediainfo \
    && rm -rf /var/lib/apt/lists/*

# Create the prowlarr user and group
RUN groupadd -r prowlarr && useradd -r -g prowlarr prowlarr

# Create necessary directories
RUN mkdir -p /opt/Prowlarr /var/lib/prowlarr

# Download and install prowlarr
RUN ARCH=$(dpkg --print-architecture) && \
    DLURL="https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}" && \
    curl -L -o /tmp/prowlarr.tar.gz $DLURL && \
    tar -xzf /tmp/prowlarr.tar.gz -C /opt/Prowlarr --strip-components=1 && \
    rm /tmp/prowlarr.tar.gz

# Set correct permissions
RUN chown -R prowlarr:prowlarr /opt/Prowlarr /var/lib/prowlarr

# Expose necessary port
EXPOSE 9696

# Switch to the prowlarr user
USER prowlarr

# Command to run prowlarr
CMD ["/opt/Prowlarr/Prowlarr", "-nobrowser", "-data=/var/lib/prowlarr"]


# Install Radarr

# Install Sonarr

# Install qBittorrent

# Set up service ports
#EXPOSE 9696 7878 8989 8080 6881

# Start all services
#CMD ["/bin/bash", "-c", "service prowlarr start && service radarr start && service sonarr start && qbittorrent-nox"]
