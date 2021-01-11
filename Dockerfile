# This Dockerfile is used to build an headles vnc image based on Ubuntu
# This is completely taken from https://github.com/ConSol/docker-headless-vnc-container
#with minor edits / commented out things. This setup is pretty minimal 
# docker run --rm -p 5901:5901 -p 6901:6901 test
#update this?
FROM ubuntu:16.04
#Note that our current rdesktop is based off of 18.04 so that may explain some differences in installation
# because am currently just copy pasting 

#MAINTAINER Simon Hofmann "simon.hofmann@consol.de"
#ENV REFRESHED_AT 2018-10-29

#metadata to the image
#LABEL io.k8s.description="Headless VNC Container with Xfce window manager, firefox and chromium" \
#      io.k8s.display-name="Headless VNC Container based on Ubuntu" \
#      io.openshift.expose-services="6901:http,5901:xvnc" \
#      io.openshift.tags="vnc, ubuntu, xfce" \
#      io.openshift.non-scalable=true

## Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
# can edit this as we please
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x1024 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

#CLEANUP SCRIPT 
COPY /src/clean-layer.sh  /usr/bin/clean-layer.sh
RUN \
    chmod u+x /usr/bin/clean-layer.sh

### Add all install scripts for further steps
# Contains a FF install, noVNC - HTML5 based VNC Viewer, and some user permission script
ADD ./src/common/install/ $INST_SCRIPTS/
# Contains Chrome, IceWM window manager (not req'd for us), custom fonts, libnss-wrapper (allow us to CRUD unix users), tigervnc
# also contains in tools: vim, wget, net-tools, locales python-numpy, generates EN locales
#  and contains installs for the xfce4 UI components
ADD ./src/ubuntu/install/ $INST_SCRIPTS/
#probably just adds execute? 
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
#this changes based on our thing 
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install custom fonts
RUN $INST_SCRIPTS/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firefox and chrome browser
RUN $INST_SCRIPTS/firefox.sh
RUN $INST_SCRIPTS/chrome.sh

### Install xfce UI
RUN $INST_SCRIPTS/xfce_ui.sh
ADD ./src/common/xfce/ $HOME/

### configure startup
RUN $INST_SCRIPTS/libnss_wrapper.sh
ADD ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME


#Image size currently (after above) = 1.22 GB

#Adding stuff from our current RDESKTOP HERE
#gpg-agent and libcurl4 may fail rn because the current use is ubuntu 16.04 and this is copied from one that uses 18.04
RUN \
    # TODO add repos?
    # add-apt-repository ppa:apt-fast/stable
    # add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main'
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        # This is necessary for apt to access HTTPS sources: 
        apt-transport-https \
        gnupg-agent \
        #remove for now check build size gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        #removed for now, check build ssizelibcurl4 \
        curl \
        wget \
        cron \
        openssl \
        iproute2 \
        psmisc \
        tmux \
        dpkg-sig \
        uuid-dev \
        csh \
        xclip \
        clinfo \
        libgdbm-dev \
        libncurses5-dev \
        gawk \
        # Simplified Wrapper and Interface Generator (5.8MB) - required by lots of py-libs
        swig \
        # Graphviz (graph visualization software) (4MB)
        graphviz libgraphviz-dev \
        # Terminal multiplexer
        screen \
        # Editor
        nano \
        # Find files
        locate \
        # Dev Tools
        # sqlite3 \
        # XML Utils
        xmlstarlet \
        #  R*-tree implementation - Required for earthpy, geoviews (3MB)
        libspatialindex-dev \
        # Search text and binary files
        yara \
        # Minimalistic C client for Redis
        libhiredis-dev \
        libleptonica-dev \
        # GEOS library (3MB)
        libgeos-dev \
        # style sheet preprocessor
        less \
        # Print dir tree
        tree \
        # Bash autocompletion functionality
        bash-completion \
        # ping support
        iputils-ping \
        # Json Processor
        jq \
        rsync \
        # VCS:
        git \
        subversion \
        jed \
        # odbc drivers
        unixodbc unixodbc-dev \
        # Image support
        libtiff-dev \
        libjpeg-dev \
        libpng-dev \
        # TODO: no 18.04 installation candidate: libjasper-dev \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxext-dev \
        libxrender1 \
        libzmq3-dev \
        # protobuffer support
        protobuf-compiler \
        libprotobuf-dev \
        libprotoc-dev \
        autoconf \
        automake \
        libtool \
        cmake  \
        fonts-liberation \
        google-perftools \
        # Compression Libs
        # also install rar/unrar? but both are propriatory or unar (40MB)
        zip \
        gzip \
        unzip \
        bzip2 \
        lzop \
        bsdtar \
        zlibc \
        # unpack (almost) everything with one command
        unp \
        libbz2-dev \
        liblzma-dev \
        zlib1g-dev && \
    # configure dynamic linker run-time bindings
    ldconfig
RUN clean-layer.sh
#Image size after this 100 or so installs = 1.49 


# TINI
ARG SHA256=12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini -O /tini && \
    echo "${SHA256} /tini" | sha256sum -c - && \
    chmod +x /tini
    RUN clean-layer.sh
#1.49 gigs




#
# Install Miniconda: https://repo.continuum.io/miniconda/
# Also moved DATA SCIENCE BASICS and the Conda Solving Environemnt fix here: 
# All base conda in one layer brings down image size
ENV \
    CONDA_DIR=/opt/conda \
    PYTHON_VERSION="3.7.7" \
    CONDA_PYTHON_DIR=/opt/conda/lib/python3.7 \
    CONDA_VERSION="4.7.12"
ARG SHA256=a23fcffe97690d3bbcd34cda798c3a3318e0f35d863c5d4aca3fc983fe8450b7
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ${HOME}/miniconda.sh && \
    echo "${SHA256} ${HOME}/miniconda.sh" | sha256sum -c - && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    export PATH=$CONDA_DIR/bin:$PATH && \
    rm ~/miniconda.sh && \
    # Update conda
    $CONDA_DIR/bin/conda update -y -n base -c defaults conda && \
    $CONDA_DIR/bin/conda update -y setuptools && \
    $CONDA_DIR/bin/conda install -y conda-build && \
    # Add conda forge - Append so that conda forge has lower priority than the main channel
    $CONDA_DIR/bin/conda config --system --append channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    ## Conda Solving Environment Fix: Turn off channel priority
    conda config --set channel_priority false && \
    # Update selected packages - install python 3.7.x
    $CONDA_DIR/bin/conda install -y --update-all python=$PYTHON_VERSION && \
    # Link Conda
    ln -s $CONDA_DIR/bin/python /usr/local/bin/python && \
    ln -s $CONDA_DIR/bin/conda /usr/bin/conda && \
    # Update pip
    $CONDA_DIR/bin/pip install --upgrade pip && \
    ### DATA SCIENCE BASICS ###
    ### Install main data science libs
    # Link Conda - All python are linke to the conda instances 
    # Linking python 3 crashes conda -> cannot install anyting - remove instead
    ln -s -f $CONDA_DIR/bin/python /usr/bin/python && \
    apt-get update && \
    # upgrade pip
    pip install --upgrade pip && \
    conda install -y --update-all nomkl && \
    conda install -y --update-all \
            'python='$PYTHON_VERSION \
            tqdm \
            pyzmq \
            cython \
            graphviz \
            numpy \
            matplotlib \
            scipy \
            requests \
            urllib3 \
            pandas \
            six \
            future \
            protobuf \
            zlib \
            boost \
            psutil \
            PyYAML \
            python-crontab \
            ipykernel \
            cmake \
            joblib \
            Pillow \
            ipython \
            notebook \
            # Selected by library evaluation
            networkx \
            click \
            docutils \
            imageio \
            tabulate \
            flask \
            dill \
            regex \
            toolz \
            jmespath && \
    # OpenMPI support
    apt-get install -y --no-install-recommends libopenmpi-dev openmpi-bin && \
    # Install numba
    conda install -y numba && \
    # libartals == 40MB liblapack-dev == 20 MB
    apt-get install -y --no-install-recommends liblapack-dev libatlas-base-dev libeigen3-dev libblas-dev && \
    # pandoc -> installs libluajit -> problem for openresty
    # HDF5 (19MB)
    apt-get install -y libhdf5-dev && \
    ### END DATA SCIENCE BASICS ###
    # Cleanup - Remove all here since conda is not in path as of now
    $CONDA_DIR/bin/conda clean -y --packages && \
    $CONDA_DIR/bin/conda clean -y -a -f  && \
    $CONDA_DIR/bin/conda build purge-all
#extra Jupyter stuff 3.49 GIGABYTES WHOOO LAD 
#this install is 2 gigs
#try doing some cleanup see what that does

RUN clean-layer.sh
#after clean up its slightly bigger... 


#more stuff
ENV PATH=$CONDA_DIR/bin:$PATH

# There is nothing added yet to LD_LIBRARY_PATH, so we can overwrite
ENV LD_LIBRARY_PATH=$CONDA_DIR/lib 

# Install node.js
#PLEASE NOTE THAT THE security thing is commented out as well as --allow-unauthenticated
#THIS IS NOT SERIOUS JUST USE FOR TESTING SIZES
ARG VERSION=v12.18.0
ARG DISTRO=linux-x64
ARG SHA256=2febc2506c298048bfddf896056be6191c1f08716876d960a4990bd63a7fe05a
RUN \
    wget --quiet https://nodejs.org/dist/${VERSION}/node-${VERSION}-${DISTRO}.tar.xz -O /tmp/nodejs.tar.xz && \
    echo "${SHA256} /tmp/nodejs.tar.xz" | sha256sum -c - && \
    mkdir -p /usr/local/lib/nodejs && \
    tar -xJvf /tmp/nodejs.tar.xz -C /usr/local/lib/nodejs && \
    rm  /tmp/nodejs.tar.xz && \
    export PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH && \
    # Install YARN
    #cat $RESOURCES_PATH/tools/yarn_pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends --allow-unauthenticated yarn && \
    # Install libxkbfile-dev which is necessary for certain YARN and NPM commands/installs
    apt-get install -y libxkbfile-dev && \
    # Install typescript 
    /usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/npm install -g typescript && \
    # Install webpack - 32 MB
    /usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin/npm install -g webpack && \
    # Cleanup
    clean-layer.sh 

ENV PATH=/usr/local/lib/nodejs/node-$VERSION-$DISTRO/bin:$PATH

#after this its 3.65 so ~= 250 extra mbs 


# Install Terminal / GDebi (Package Manager) / Glogg (Stream file viewer) & archive tools
# This might be just ok, installs some tools so yea 
#chromium is commented out here but eh 
# Discover Tools:
# https://wiki.ubuntuusers.de/Startseite/
# https://wiki.ubuntuusers.de/Xfce_empfohlene_Anwendungen/
# https://goodies.xfce.org/start
# https://linux.die.net/man/1/
RUN \
    apt-get update && \
    # Configuration database - required by git kraken / atom and other tools (1MB)
    apt-get install -y --no-install-recommends gconf2 && \
    apt-get install -y --no-install-recommends xfce4-terminal && \
    apt-get install -y --no-install-recommends --allow-unauthenticated xfce4-taskmanager  && \
    # Install gdebi deb installer
    apt-get install -y --no-install-recommends gdebi && \
    # Search for files
    apt-get install -y --no-install-recommends catfish && \
    # TODO: Unable to locate package:  apt-get install -y --no-install-recommends gnome-search-tool && 
    apt-get install -y --no-install-recommends font-manager && \
    # vs support for thunar
    apt-get install -y thunar-vcs-plugin && \
    # Streaming text editor for large files
    apt-get install -y --no-install-recommends glogg  && \
    apt-get install -y --no-install-recommends baobab && \
    # Lightweight text editor
    apt-get install -y mousepad && \
    apt-get install -y --no-install-recommends vim && \
    # Process monitoring
    apt-get install -y htop && \
    # Install Archive/Compression Tools: https://wiki.ubuntuusers.de/Archivmanager/
    apt-get install -y p7zip p7zip-rar && \
    apt-get install -y --no-install-recommends thunar-archive-plugin && \
    apt-get install -y xarchiver && \
    # DB Utils
    apt-get install -y --no-install-recommends sqlitebrowser && \
    # Install nautilus and support for sftp mounting
    apt-get install -y --no-install-recommends nautilus gvfs-backends && \
    # Install gigolo - Access remote systems
    apt-get install -y --no-install-recommends gigolo gvfs-bin && \
    # xfce systemload panel plugin - needs to be activated
    apt-get install -y --no-install-recommends xfce4-systemload-plugin && \
    # Leightweight ftp client that supports sftp, http, ...
    apt-get install -y --no-install-recommends gftp && \
    # Install chrome
    # apt-get install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg && \
    # ln -s /usr/bin/chromium-browser /usr/bin/google-chrome && \
    # Cleanup
    # Large package: gnome-user-guide 50MB app-install-data 50MB
    apt-get remove -y app-install-data gnome-user-guide && \ 
    clean-layer.sh
#roughly around 200mbs install
#after this size is 3.81gigs

#install vscode next. Extra 200 mbs 
COPY /tools/vs-code-desktop.sh  /tools/vs-code-desktop.sh
#RUN \
#    /bin/bash /tools/vs-code-desktop.sh --install && \
    # Cleanup
#    clean-layer.sh
RUN ls
#now at 4.09 gigs 


USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
