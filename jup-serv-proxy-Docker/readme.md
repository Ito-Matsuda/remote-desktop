This hopefully does stuff without needing all the other files. 
I just want to pip install man

#This python 3 install seems to mess with it
RUN python3 -m pip install \ 
    'git+git://github.com/Ito-Matsuda/jupyter-desktop-server#egg=jupyter-desktop-server'


The following WORKS

```
FROM jupyter/base-notebook:python-3.7.6


USER root

RUN apt-get -y update \
 && apt-get install -y dbus-x11 \
   firefox \
   xfce4 \
   xfce4-panel \
   xfce4-session \
   xfce4-settings \
   xorg \
   xubuntu-icon-theme

# Remove light-locker to prevent screen lock
RUN wget 'https://sourceforge.net/projects/turbovnc/files/2.2.5/turbovnc_2.2.5_amd64.deb/download' -O turbovnc_2.2.5_amd64.deb && \
   apt-get install -y -q ./turbovnc_2.2.5_amd64.deb && \
   apt-get remove -y -q light-locker && \
   rm ./turbovnc_2.2.5_amd64.deb && \
   ln -s /opt/TurboVNC/bin/* /usr/local/bin/

RUN apt-get install -y git
#This python3 pip install messes it all up
# --user goes back to 'Directory . is not installable. '
RUN python3 -m pip install \ 
    'git+git://github.com/Ito-Matsuda/jupyter-desktop-server#egg=jupyter-desktop-server'
#where is this installed?? is it this that's messing with it. 
#from the docker build... 
#Successfully built jupyter-desktop-server
#Installing collected packages: async-timeout, typing-extensions, multidict, yarl, aiohttp, simpervisor, jupyter-server-proxy, jupyter-desktop-server
#Successfully installed aiohttp-3.7.3 async-timeout-3.0.1 jupyter-desktop-server-0.1.3 jupyter-server-proxy-1.5.3 multidict-5.1.0 simpervisor-0.4 typing-extensions-3.7.4.3 yarl-1.6.3

#try their repo #nope
#RUN python3 -m pip install \ 
##    'git+git://github.com/yuvipanda/jupyter-desktop-server#egg=jupyter-desktop-server'

# apt-get may result in root-owned directories/files under $HOME
RUN chown -R $NB_UID:$NB_GID $HOME

ADD . /opt/install
RUN fix-permissions /opt/install


#hmmm im surprised here that user is before the RUN 
#yet if you place it after the conda env update it gives the pip subproccess error 
USER $NB_USER


#RUN ls -a 
#RUN echo $PWD
#RUN chown -R jovyan /home/jovyan
# RUN chown -R jovyan /opt/conda/lib/python3.7/site-packages/async_timeout-3.0.1.dist-info/ # not permitted.

#RUN apt-get install -y build-essential

#RUN conda info 
RUN cd /opt/install && \
   conda env update -n base --file environment.yml
#need websockify

#USER $NB_USER if you place it here the conda env fails with pip subprocess error. 

ENV DEFAULT_JUPYTER_URL=desktop
COPY start-custom.sh /usr/local/bin/
CMD ["start-custom.sh"]

#this works 100% (on the above directory)

```

DO make note that this has to be the environment.yml file
```
channels:
  - conda-forge
dependencies:
  - websockify
```
If I had the other 'dependencies' there's a whole lot of who-knows-what in there that causes weird file behaviour and installations
