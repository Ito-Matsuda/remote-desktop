# This Dockerfile is used to build an headles vnc image based on Ubuntu
# This is completely taken from https://github.com/ConSol/docker-headless-vnc-container
#with minor edits / commented out things. This setup is pretty minimal 
# docker run --rm -p 5901:5901 -p 6901:6901 test

#Update to at least use 18.04
#doesnt work, look into gtk2 vs gtk3 stuff? check out command line apps? check out window managers?
#FROM ubuntu:18.04

#works version is = xfce4.12 
FROM ubuntu:16.04 

#doesnt work
#FROM ubuntu:20.04

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


# TINI
ARG SHA256=12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini -O /tini && \
    echo "${SHA256} /tini" | sha256sum -c - && \
    chmod +x /tini
    RUN clean-layer.sh
#1.49 gigs

#### UP TO HERE IS FINE at 1.57

#install french locale. something in maybe tools.sh is messing with this 
#If this is ran AFTER the xfce ui then main menu stuff does not get translated (like thunar again...)
RUN \
    apt-get update && \
    apt-get install -y locales && \
    sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=fr_FR.UTF-8 LANGUAGE=fr_FR.UTF-8 && \
    clean-layer.sh
ENV LANG='fr_FR.UTF-8' LANGUAGE='fr_FR.UTF-8'


### Install xfce UI
#this probably needs to be ran last, maybe not but put here anyways its pretty fast
RUN $INST_SCRIPTS/xfce_ui.sh
COPY ./src/common/xfce/ $HOME/

### configure startup #this should probably be ran last?
RUN $INST_SCRIPTS/libnss_wrapper.sh
COPY ./src/common/scripts $STARTUPDIR
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME


USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
