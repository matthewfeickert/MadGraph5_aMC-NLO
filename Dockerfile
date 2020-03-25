FROM python:2.7-slim

MAINTAINER Matthew Feickert <matthewfeickert@users.noreply.github.com>

USER root
WORKDIR /usr/local

SHELL [ "/bin/bash", "-c" ]

RUN apt-get -qq -y update && \
    apt-get -qq -y install \
      gcc \
      g++ \
      gfortran \
      make \
      vim \
      zlibc \
      zlib1g-dev \
      libbz2-dev \
      rsync \
      bash-completion \
      python2-dev \
      wget && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt-get/lists/*

# Install FastJet
ARG FASTJET_VERSION=3.3.3
RUN mkdir /code && \
    cd /code && \
    wget http://fastjet.fr/repo/fastjet-${FASTJET_VERSION}.tar.gz && \
    tar xvfz fastjet-${FASTJET_VERSION}.tar.gz && \
    cd fastjet-${FASTJET_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local \
      --enable-pyext=yes && \
    make -j$(($(nproc) - 1)) && \
    make check && \
    make install && \
    rm -rf /code

# Install LHAPDF
ARG LHAPDF_VERSION=6.2.3
RUN mkdir /code && \
    cd /code && \
    wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF_VERSION}.tar.gz -O LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    tar xvfz LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    cd LHAPDF-${LHAPDF_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8301
# PYTHON_VERSION already exists in the base image
RUN mkdir /code && \
    cd /code && \
    wget http://home.thep.lu.se/~torbjorn/pythia8/pythia${PYTHIA_VERSION}.tgz && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION=${PYTHON_VERSION::-2} && \
    ./configure \
      --prefix=/usr/local \
      --arch=Linux \
      --cxx=g++ \
      --with-gzip \
      --with-python-bin=/usr/local/bin \
      --with-python-lib=/usr/lib/python${PYTHON_MINOR_VERSION} \
      --with-python-include=/usr/include/python${PYTHON_MINOR_VERSION} && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install MadGraph5_aMC@NLO
ARG MG_VERSION=2.7.2
RUN cd /usr/local && \
    wget -q https://launchpad.net/mg5amcnlo/2.0/2.7.x/+download/MG5_aMC_v${MG_VERSION}.tar.gz && \
    tar xzf MG5_aMC_v${MG_VERSION}.tar.gz && \
    rm MG5_aMC_v${MG_VERSION}.tar.gz

# Install NumPy and pylhe
COPY requirements.txt requirements.txt
RUN python -m pip install --upgrade --no-cache-dir pip setuptools wheel && \
    python -m pip install --upgrade --no-cache-dir -r requirements.txt && \
    rm requirements.txt

# Enable tab completion by uncommenting it from /etc/bash.bashrc
# The relevant lines are those below the phrase "enable bash completion in interactive shells"
RUN export SED_RANGE="$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+1)),$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+7))" && \
    sed -i -e "${SED_RANGE}"' s/^#//' /etc/bash.bashrc && \
    unset SED_RANGE

# Create user "docker"
#RUN useradd -m docker && \
#    cp /root/.bashrc /home/docker/ && \
#    mkdir /home/docker/data && \
#    chown -R --from=root docker /home/docker && \
#    chown -R --from=root docker /usr && \
#    chown -R --from=root docker /usr/local

## Move files someplace
#RUN cp -r /usr/local/MG5_aMC_v2_7_2 /home/docker/ && \
#    chown -R --from=root docker /home/docker

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV HOME /home/docker
WORKDIR ${HOME}/data
#ENV USER docker
#USER docker
ENV PYTHONPATH=/usr/local/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PATH ${HOME}/.local/bin:$PATH
ENV PATH /usr/local/MG5_aMC_v2_7_2/bin:$PATH

ENTRYPOINT [ "/bin/bash" ]
