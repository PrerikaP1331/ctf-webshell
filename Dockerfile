# --- Custom Docker Image for CTF Webshell (v3 - Final) ---

# Start from the official, up-to-date Kali Linux base image
FROM kalilinux/kali-rolling

# Set the Environment PATH to ensure all system tools can be found by commands.
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV TERM=xterm-256color \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Set the working directory for the user inside the container
WORKDIR /home/ctf-user

# --- Install ttyd Manually ---
# Download the pre-compiled binary for Linux x86_64
ADD https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 /usr/local/bin/ttyd
# Make the downloaded file executable
RUN chmod +x /usr/local/bin/ttyd

# --- Install Kali Tools ---
# Update package lists and install your comprehensive list of CTF tools.
RUN apt-get update && apt-get install -y \
    # General & All-Purpose
    python3 python3-pip git \
    netcat-traditional \
    curl wget \
    unzip\
    nmap \
    dirb \
    # Web Exploitation
    sqlmap \
    gobuster \
    nikto \
    # Reverse Engineering
    radare2 \
    # Binary Exploitation (Pwn)
    gdb \
    python3-pwntools \
    # Forensics
    binwalk \
    binutils \
    foremost \
    # Cryptography
    john \
    hashcat \
    # Steganography
    steghide \
    libimage-exiftool-perl \
    # Dependencies for other tools
    build-essential \
    zsh \
    && \
    # Clean up apt caches to keep the image size down
    rm -rf /var/lib/apt/lists/*

# --- COMPILE WHITESPACE INTERPRETER ---
# Clone the official repository for the 'wspace' interpreter
RUN git clone https://github.com/wspace/wspace.git /opt/wspace && \
    # Navigate into the directory
    cd /opt/wspace && \
    # Run the make command to compile the 'wspace' executable
    make && \
    # Create a symbolic link so the 'wspace' command is available everywhere
    ln -s /opt/wspace/wspace /usr/local/bin/wspace

# Set ZSH as the default shell for the root user
RUN chsh -s /bin/zsh root

# Configure ZSH with classic Kali prompt format
RUN echo 'setopt PROMPT_SUBST' > /root/.zshrc && \
    echo 'autoload -U colors && colors' >> /root/.zshrc && \
    echo 'PROMPT="%F{green}┌──(%F{red}%n%f%F{blue}㉿%m%f)-[%F{cyan}%~%f]%f"' >> /root/.zshrc && \
    echo 'PROMPT+=$'"'"'\\n%F{green}└─%F{red}%#%f '"'"'' >> /root/.zshrc && \
    echo 'cd /home/ctf-user' >> /root/.zshrc

# Use Azure's PORT env when present (fallback to 8080)
ENV PORT=8080

# Expose the port the app listens on
EXPOSE 8080

# Start ttyd with ZSH as the default Kali shell for proper prompt
CMD ["ttyd", "-p", "8080", "--client-option", "rendererType=webgl","-i", "0.0.0.0", "-W", "-t", "titleFixed=Kali Linux Terminal", "zsh"]
