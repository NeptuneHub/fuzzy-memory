# Use a base image that supports multiple services
FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    libchromaprint-tools \
    mediainfo \
    && rm -rf /var/lib/apt/lists/*

# Install Prowlarr
# Create the prowlarr user and group
RUN groupadd -r prowlarr && useradd -r -g prowlarr prowlarr

# Create necessary directories for Prowlarr
RUN mkdir -p /opt/Prowlarr /var/lib/prowlarr

# Download and install Prowlarr
RUN ARCH=$(dpkg --print-architecture) && \
    DLURL="https://prowlarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}" && \
    curl -L -o /tmp/prowlarr.tar.gz $DLURL && \
    tar -xzf /tmp/prowlarr.tar.gz -C /opt/Prowlarr --strip-components=1 && \
    rm /tmp/prowlarr.tar.gz

# Set correct permissions for Prowlarr
RUN chown -R prowlarr:prowlarr /opt/Prowlarr /var/lib/prowlarr

# Install Radarr
# Create the radarr user and group
RUN groupadd -r radarr && useradd -r -g radarr radarr

# Create necessary directories for Radarr
RUN mkdir -p /opt/Radarr /var/lib/radarr

# Download and install Radarr
RUN ARCH=$(dpkg --print-architecture) && \
    DLURL="https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=${ARCH}" && \
    curl -L -o /tmp/radarr.tar.gz $DLURL && \
    tar -xzf /tmp/radarr.tar.gz -C /opt/Radarr --strip-components=1 && \
    rm /tmp/radarr.tar.gz

# Set correct permissions for Radarr
RUN chown -R radarr:radarr /opt/Radarr /var/lib/radarr

# Expose necessary ports for both services
EXPOSE 9696 7878

# Create a script to run both services
RUN echo '#!/bin/bash\n\
/opt/Prowlarr/Prowlarr -nobrowser -data=/var/lib/prowlarr &\n\
/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr &\n\
wait' > /usr/local/bin/start-services.sh && chmod +x /usr/local/bin/start-services.sh

# Switch to root user to start both services
USER root

# Command to run both services
CMD ["/usr/local/bin/start-services.sh"]
