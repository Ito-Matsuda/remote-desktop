# Custom image from https://hub.docker.com/r/consol/ubuntu-xfce-vnc\
#Connect at http://localhost:6901/?password=vncpassword
#docker run --rm -p 5901:5901 -p 6901:6901 test 
#Do I really need the "clean-layer script?"
FROM consol/ubuntu-xfce-vnc


# Switch to root user to install additional software
USER 0
#THIS ALL WORKS 



#Must add the add-apt-repository functionality, not included in our base 
RUN apt-get update &&\
    apt-get install software-properties-common -y



# LibreOffice
RUN add-apt-repository ppa:libreoffice/ppa 
RUN apt-get -y install libreoffice-calc libreoffice-gtk3 
RUN apt-get install -y libreoffice-help-fr libreoffice-l10n-fr
#Question, do I need -y all the time? I did not need it 
#When i was doing it on the og remote desktop

#Firefox French https://packages.ubuntu.com/groovy/firefox-locale-fr
#This is not enough
RUN apt-get install firefox-locale-fr
#Am thinking we uninstall and just re-install
#https://github.com/StatCan/kubeflow-containers-desktop/blob/master/base/resources/tools/firefox.sh
#https://github.com/ConSol/docker-headless-vnc-container/blob/master/src/common/install/firefox.sh


## Install a gedit
#RUN yum install -y gedit \
#    && yum clean all

#Test with LC_ALL, ideally should not be set? at least in readings yes 
#Test with env vars at the end so it doesn rebuild from top
ENV VNC_RESOLUTION=1600x900

RUN mkdir -p resources/scripts



#Install the French Locale
RUN \
    apt-get update && \
    apt-get install -y locales && \
    sed -i -e 's/# fr_CA.UTF-8 UTF-8/fr_CA.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=fr_CA.UTF-8 
   
ENV LANG="fr_CA.UTF-8" LANGUAGE="fr_CA.UTF-8" LC_ALL=""

## switch back to default user
USER 1000
