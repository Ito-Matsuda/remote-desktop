# This Dockerfile is used to build an headles vnc image based on Ubuntu
# This is completely taken from https://github.com/ConSol/docker-headless-vnc-container
#with minor edits / commented out things. This setup is pretty minimal 
# docker run --rm -p 5901:5901 -p 6901:6901 test

#Update to at least use 18.04
FROM ubuntu:18.04

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

#CLEANUP SCRIPT could add the 'fix-permissions' here as well 
COPY /src/clean-layer.sh  /usr/bin/clean-layer.sh
RUN chmod u+x /usr/bin/clean-layer.sh

### Add all install scripts for further steps
COPY ./src/common/install/ $INST_SCRIPTS/
COPY ./src/ubuntu/install/ $INST_SCRIPTS/
#probably just adds execute? 
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

### Install some common tools
RUN $INST_SCRIPTS/tools.sh
#this changes based on our thing 
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

### Install custom fonts
RUN $INST_SCRIPTS/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

### Install firefox and chrome browser
RUN $INST_SCRIPTS/firefox.sh
RUN $INST_SCRIPTS/chrome.sh


#Image size currently (after above) = 1.22 GB (befiore moving xcfe ui to bottom)
#up to here is everything that was in the base Blair

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
        gpg-agent \
        gnupg2 \
        ca-certificates \
        build-essential \
        pkg-config \
        software-properties-common \
        lsof \
        net-tools \
        libcurl4 \
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


#### UP TO HERE IS FINE at 1.57



# Install Terminal / GDebi (Package Manager) / Glogg (Stream file viewer) & archive tools
# all these seem to install fine 
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
    # Install gdebi deb installer installs 
    apt-get install -y --no-install-recommends gdebi && \
    # Search for files installs 
    apt-get install -y --no-install-recommends catfish && \
    #installs
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
    apt-get remove -y app-install-data gnome-user-guide && \ 
    clean-layer.sh

COPY /tools/vs-code-desktop.sh  /tools/vs-code-desktop.sh
RUN \
    /bin/bash /tools/vs-code-desktop.sh --install 
    # Cleanup
#    clean-layer.sh
RUN echo "vscode should be installed"
#now at 4.09 gigs 


### Install xfce UI
#this probably needs to be ran last 
RUN $INST_SCRIPTS/xfce_ui.sh
COPY ./src/common/xfce/ $HOME/

### configure startup #this should probably be ran last?
RUN $INST_SCRIPTS/libnss_wrapper.sh
COPY ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME


USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
