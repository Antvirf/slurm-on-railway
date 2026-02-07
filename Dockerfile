FROM ubuntu:24.04
WORKDIR /opt/

# Compilation requirements as per https://slurm.schedmd.com/quickstart_admin.html#manual_build
RUN apt-get update && apt-get -y  dist-upgrade
#RUN apt-get install -y \
    # Packages needed for compilation
    #build-essential fakeroot devscripts equivs

# Build tooling
RUN apt-get install -y \
    # Build tooling
    build-essential curl gcc make \
    # Slurm deps
    libjwt-dev \
    libcurl4-openssl-dev \
    libfreeipmi-dev \
    libhdf5-dev \
    libreadline-dev \
    libgtk2.0-dev \
    libhwloc-dev \
    libbpf-dev \
    libjson-c-dev \
    libhttp-parser-dev \
    libyaml-dev \
    libdbus-1-dev

# Download slurm, extract and compile
ENV SLURM_VERSION=24.11.3
RUN curl -O https://download.schedmd.com/slurm/slurm-${SLURM_VERSION}.tar.bz2 && \
    tar -xaf slurm*tar.bz2 && \
    cd /opt/slurm-${SLURM_VERSION} && \
    ./configure \
        --sysconfdir=/etc/slurm/ \
        --prefix=/bin/ \
        --enable-cgroupv2 \
        --with-libcurl \
        --with-jwt \
        --with-json \
        --with-http-parser \
        --with-yaml \
        --without-munge && \
        #--with-freeipmi
    make install

RUN mkdir -p /etc/slurm /var/spool/slurmctld /var/run /var/log/slurm
COPY slurm.conf /etc/slurm/slurm.conf
COPY create-slurm-key.sh /usr/local/bin/create-slurm-key.sh
RUN chmod +x /usr/local/bin/create-slurm-key.sh && /usr/local/bin/create-slurm-key.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 6817

# -D = run in foreground
WORKDIR /bin/sbin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
