# Dockerfile for cliHelpLine multi-language test environment
# Supports: Bash, Zsh, Python 3, Node.js, Ruby, Perl, PHP, Lua, R, PowerShell Core, Tcl, AWK
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install common tools, package management prerequisites, and standard scripting runtimes
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    diffutils \
    gawk \
    bsdextrautils \
    bash \
    zsh \
    python3 \
    nodejs \
    ruby \
    perl \
    php-cli \
    lua5.4 \
    r-base-core \
    tcl \
    && rm -rf /var/lib/apt/lists/*

# Install PowerShell Core (multi-arch arm64 / amd64 from Microsoft repo)
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
      > /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends powershell && \
    rm -rf /var/lib/apt/lists/*

# Set default working directory
WORKDIR /workspace

# Default command runs the test suite
CMD ["bash", "tests/test_cliHelpLine.sh"]
