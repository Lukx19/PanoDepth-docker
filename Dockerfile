FROM nvidia/cudagl:9.0-runtime-ubuntu16.04

RUN mkdir -p /workspace/mnt

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    iputils-ping \
    mc \
    wget \
    curl \
    zip \
    unzip \
    bzip2 \
    tmux \
    screen \
    htop \
    libopenexr-dev \
    less \
    nano \
    git \
    pigz \
    build-essential \
    software-properties-common \
    libeigen3-dev \
    libproj-dev \
    libstdc++6 && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    mv Miniconda3-latest-Linux-x86_64.sh miniconda.sh && \
    sh ./miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /root/.bashrc

RUN . /root/.bashrc && \
    conda update -n base -c defaults conda

COPY ./environment.yml /tmp/environment.yml

RUN . /root/.bashrc && \
    conda env create -f /tmp/environment.yml

# Taking care of Plotly rendering to file
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    libxtst6 \
    libxss1 \
    libgconf-2-4 \
    libnss3-dev \
    xvfb \
    libasound-dev \
    libx11-xcb-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mv /opt/conda/envs/core/bin/orca /opt/conda/envs/core/bin/orca_orig
COPY orca /opt/conda/envs/core/bin/orca
RUN chmod +x /opt/conda/envs/core/bin/orca

# Pull the environment name out of the environment.yml
RUN echo "conda activate $(head -1 /tmp/environment.yml | cut -d' ' -f2)" >> /root/.bashrc
ENV PATH /opt/conda/envs/$(head -1 /tmp/environment.yml | cut -d' ' -f2)/bin:$PATH


COPY ./entrypoint.sh /root/entrypoint.sh
WORKDIR /workspace/
ENTRYPOINT [ "/bin/sh","/root/entrypoint.sh" ]
CMD [ "/bin/bash" ]


