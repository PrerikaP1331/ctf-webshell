# --- Custom Docker Image for CTF Webshell (v3 - Final) ---

# Start from the official, up-to-date Kali Linux base image
FROM kalilinux/kali-rolling

# Set the Environment PATH to ensure all system tools can be found by commands.
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Set the working directory for the user inside the container
WORKDIR /home/ctf-user

# --- Install ttyd Manually ---
# Download the pre-compiled binary for Linux x86_64
ADD https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 /usr/local/bin/ttyd
# Make the downloaded file executable
RUN chmod +x /usr/local/bin/ttyd

# --- Install Kali Tools ---
# Install the default Kali toolset.
RUN apt-get update && apt-get install -y \
    kali-linux-default \
    && rm -rf /var/lib/apt/lists/*

# 'ttyd' will run on port 7681 inside the container
EXPOSE 7681

# --- THE FIX IS HERE ---
# The command that will run when a container is started from this image.
# We have added the '--client-option allow-all-origins=true' flag.
# This tells the ttyd server to accept the WebSocket connection from your browser,
# which solves the "can't type" issue.
CMD ["ttyd", "--port", "7681", "--all-interfaces", "--client-option", "allow-all-origins=true", "bash"]