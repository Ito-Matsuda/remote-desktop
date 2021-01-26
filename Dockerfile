# This Dockerfile is used to build an headles vnc image based on Ubuntu
# This is completely taken from https://github.com/ConSol/docker-headless-vnc-container
#with minor edits / commented out things. This setup is pretty minimal 
# docker run --rm -p 5901:5901 -p 6901:6901 test
# http://localhost:6901/?password=vncpassword 
#can take mo files from here (16.04) version and place it in ours to use. 

#Update to at least use 18.04
#doesnt work, look into gtk2 vs gtk3 stuff? check out command line apps? check out window managers?
FROM ubuntu:18.04

#works version is = xfce4.12 
#FROM ubuntu:16.04 

#doesnt work, but try updating xfce to 4.16
#ubuntu 20.04 seems to have up to 4.14 on the traditional apt get. 
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

RUN \
    # TODO add repos?
    # add-apt-repository ppa:apt-fast/stable
    # add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main'
    apt-get update --fix-missing && \
    apt-get install -y sudo apt-utils

### Install some common tools
#This seems fine. 
RUN $INST_SCRIPTS/tools.sh
#ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

RUN apt-get update \
    && apt -y install language-pack-fr \
    && apt -y install thunar-data \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
    && locale-gen fr_FR.UTF-8 \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8
 

### Install custom fonts
#Seems fine
RUN $INST_SCRIPTS/install_custom_fonts.sh

### Install xvnc-server & noVNC - HTML5 based VNC viewer
#seems fine, albeit maybe could be updated with a more recent version. 
RUN $INST_SCRIPTS/tigervnc.sh
RUN $INST_SCRIPTS/no_vnc.sh

#install french locale. something in maybe tools.sh is messing with this 
#If this is ran AFTER the xfce ui then main menu stuff does not get translated (like thunar again...)


RUN echo "\n HELLO \n"
RUN apt-get update && \
    apt-cache show xfce4
#this apt cache shows 4.14
RUN echo "\n HELLO \n"
#0.8.9.1-1 (matches online) for xfce4-terminal and 353-lubuntul (matches online) for xterm
RUN apt-cache show xfce4-terminal && \
    apt-cache show xterm

### Install xfce UI
#this probably needs to be ran last, maybe not but put here anyways its pretty fast
#are you telling me that apt-get install -y supervisor xfce4 xfce4-terminal xterm only gets 4.12? I know 4.14 exists 
RUN $INST_SCRIPTS/xfce_ui.sh

COPY ./src/common/xfce/ $HOME/

### configure startup #this should probably be ran last?
#libnss fine 
RUN $INST_SCRIPTS/libnss_wrapper.sh
COPY ./src/common/scripts $STARTUPDIR
#again fine 
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### Install firefox and chrome browser
#also seems fine 
COPY src/temp/firefox.sh $INST_SCRIPTS/firefox.sh
#RUN chmod +X $INST_SCRIPTS/firefox.sh
#probably just adds execute? 
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +
RUN $INST_SCRIPTS/firefox.sh
#COPY src/temp/langpack-fr@firefox.mozilla.org.xpi /usr/lib/firefox/browser/features/
#WGET this instead
#COPY src/temp/langpack-fr@firefox.mozilla.org.xpi /usr/lib/firefox/distribution/extensions/
RUN wget https://ftp.mozilla.org/pub/firefox/releases/78.6.1esr/linux-x86_64/xpi/fr.xpi -O langpack-fr@firefox.mozilla.org.xpi && \
    mkdir --parents /usr/lib/firefox/distribution/extensions/ && \
    mv langpack-fr@firefox.mozilla.org.xpi /usr/lib/firefox/distribution/extensions/
#COPY /langpack-fr@firefox.mozilla.org.xpi /usr/lib/firefox/distribution/extensions/


#auto config
COPY src/temp/autoconfig.js /usr/lib/firefox/defaults/pref/
COPY src/temp/firefox.cfg /usr/lib/firefox/

#RUN $INST_SCRIPTS/chrome.sh

#RUN apt-get install firefox-locale-fr

ENV LANGUAGE=fr_FR.UTF-8
ENV otherlang=fr

USER 1000

#fine 
ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
