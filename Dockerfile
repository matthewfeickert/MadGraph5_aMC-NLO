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
      wget && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt-get/lists/*

# Install MadGraph5_aMC@NLO
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

# Install MadGraph5_aMC@NLO
ARG MG_VERSION=2.7.2
RUN cd /usr/local && \
    wget -q https://launchpad.net/mg5amcnlo/2.0/2.7.x/+download/MG5_aMC_v${MG_VERSION}.tar.gz && \
    tar xzf MG5_aMC_v${MG_VERSION}.tar.gz && \
    rm MG5_aMC_v${MG_VERSION}.tar.gz

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
ENV PATH ${HOME}/.local/bin:$PATH
ENV PATH /usr/local/MG5_aMC_v2_7_2/bin:$PATH

ENTRYPOINT [ "/bin/bash" ]

#load MG5 configuration from ../../../../../../usr/local/MG5_aMC_v2_7_2/input/mg5_configuration.txt
#fastjet-config does not seem to correspond to a valid fastjet-config executable (v3+). We will use fjcore instead.
# Please set the 'fastjet'variable to the full (absolute) /PATH/TO/fastjet-config (including fastjet-config).
# MG5_aMC> set fastjet /PATH/TO/fastjet-config
#
#lhapdf-config does not seem to correspond to a valid lhapdf-config executable.
#Please set the 'lhapdf' variable to the (absolute) /PATH/TO/lhapdf-config (including lhapdf-config).
#Note that you can still compile and run aMC@NLO with the built-in PDFs
# MG5_aMC> set lhapdf /PATH/TO/lhapdf-config
