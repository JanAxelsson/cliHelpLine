# Dockerfile for cliHelpLine multi-language test environment
# Supports: Bash, POSIX Sh, Zsh, Fish, Python 3, Node.js, TypeScript, Ruby, Perl, PHP, Lua, R, PowerShell Core, Tcl, AWK, Julia, Crystal, Dart, Elixir, Groovy, Nim
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
    elixir \
    groovy \
    nim \
    gcc \
    pkg-config \
    libevent-dev \
    libpcre2-dev \
    libgc-dev \
    && ln -sf /usr/bin/lua5.4 /usr/local/bin/lua \
    && rm -rf /var/lib/apt/lists/*

# Install TypeScript runners (tsx, bun)
RUN npm install -g tsx bun && npm cache clean --force

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

# Install Dart (multi-arch from Google apt repository)
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/dart.gpg] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main" \
      > /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends dart && \
    rm -rf /var/lib/apt/lists/*

# Install Crystal (multi-arch arm64 / amd64 official binaries with system libgc)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then CR_ARCH="aarch64"; else CR_ARCH="x86_64"; fi && \
    curl -fsSL "https://github.com/crystal-lang/crystal/releases/download/1.22.0/crystal-1.22.0-1-linux-${CR_ARCH}.tar.gz" -o /tmp/crystal.tar.gz && \
    mkdir -p /opt/cr && \
    tar -xzf /tmp/crystal.tar.gz -C /opt/cr && \
    mv /opt/cr/crystal* /opt/crystal && \
    rm -rf /opt/cr /tmp/crystal.tar.gz && \
    ln -s /opt/crystal/bin/crystal /usr/local/bin/crystal && \
    ln -sf /usr/lib/*-linux-gnu*/libgc.a /opt/crystal/lib/crystal/libgc.a

# Set default working directory
WORKDIR /workspace

# Default command runs the test suite
CMD ["bash", "tests/test_cliHelpLine.sh"]
