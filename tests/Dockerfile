# Dockerfile for cliHelpLine multi-language test environment
# Supports: Bash, POSIX Sh, Zsh, Fish, Python 3, Node.js, TypeScript, Ruby, Perl, PHP, Lua, R, PowerShell Core, Tcl, AWK, Julia
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
    fish \
    python3 \
    nodejs \
    npm \
    ruby \
    perl \
    php-cli \
    lua5.4 \
    r-base-core \
    tcl \
    && rm -rf /var/lib/apt/lists/*

# Install TypeScript runner (tsx)
RUN npm install -g tsx && npm cache clean --force

# Install Julia (multi-arch arm64 / amd64 official binaries)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then JULIA_ARCH="aarch64"; JULIA_DIR="aarch64"; \
    else JULIA_ARCH="x86_64"; JULIA_DIR="x64"; fi && \
    JULIA_VER="1.10.12" && \
    curl -fsSL "https://julialang-s3.julialang.org/bin/linux/${JULIA_DIR}/1.10/julia-${JULIA_VER}-linux-${JULIA_ARCH}.tar.gz" -o /tmp/julia.tar.gz && \
    mkdir -p /opt/julia && \
    tar -xzf /tmp/julia.tar.gz -C /opt/julia --strip-components=1 && \
    ln -s /opt/julia/bin/julia /usr/local/bin/julia && \
    rm -f /tmp/julia.tar.gz

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
