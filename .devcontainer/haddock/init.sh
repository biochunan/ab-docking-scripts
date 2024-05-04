#!/bin/bash
# A simple script to initialize the container correctly

# Setting up Docker socket permissions
if [ -S "/var/run/docker.sock" ]; then
    sudo chown "$USERNAME:docker" /var/run/docker.sock
fi

# Execute the command provided as CMD in the Dockerfile, if any.
exec "$@"
