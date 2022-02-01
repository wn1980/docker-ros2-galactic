#FROM ros:foxy-ros-base-focal
FROM ros:galactic-ros-base-focal

LABEL maintainer="Waipot Ngamsaad <waipotn@hotmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

# install Ubuntu packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    apt-transport-https \
    curl \
    git \
    wget \
    nano \
    sudo \
    bash-completion \
    #less \
    htop \
    tmux \
    terminator \
    xfe \
    #fluxbox \
    jwm \
    xfonts-base \
    xauth \
    x11-xkb-utils \
    xkb-data \
    dbus-x11 \
    net-tools \
    iputils-ping \
    usbutils \
    tigervnc-standalone-server \
    #tigervnc-xorg-extension \
    #python-pip \
    python3-dev \
	python3-pip \
    python3-numpy \
    python3-scipy \
    gfortran \
    texinfo \
    libfftw3-dev \
    libconfig-dev \
    libasound2-dev \
    libgbm-dev \
    libnss3-dev \
	libssl-dev \
	libffi-dev \
	libatlas3-base \
	portaudio19-dev \
	ffmpeg \
	alsa-utils \
    build-essential \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install ROS packages
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    curl -L http://packages.osrfoundation.org/gazebo.key | apt-key add -

RUN apt-get update --fix-missing && apt-get upgrade --fix-missing -y
RUN apt-get install -y \
    ros-${ROS_DISTRO}-desktop \
    python3-rosdep \
    python3-colcon-common-extensions \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# update pip and install some packages
RUN curl https://bootstrap.pypa.io//get-pip.py | python3 - && \
    #curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python - && \
    pip install -U --no-cache-dir \
    	argcomplete \
        libconf \
        supervisor \
        supervisor_twiddler

# install nodejs
RUN sh -c 'echo "deb https://deb.nodesource.com/node_12.x `lsb_release -cs` main" > /etc/apt/sources.list.d/nodesource.list' && \
    curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    nodejs \
	&& rm -rf /var/lib/apt/lists/*

# update tigervnc
COPY ./app/install/tigervnc.sh /

RUN /tigervnc.sh && sudo rm -f /tigervnc.sh

# install noVNC
COPY ./app/install/no-vnc.sh /

RUN /no-vnc.sh && sudo rm -f /no-vnc.sh

# install code-server
COPY ./app/install/code-server.sh /

RUN /code-server.sh 3.12.0 && sudo rm -f /code-server.sh

# init rosdep
RUN rm /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init && \
    rm /etc/apt/apt.conf.d/docker-clean

# setup user space
RUN mkdir -p {/workspace,/app}

RUN useradd -m developer && \
    usermod -aG sudo developer && \
    usermod --shell /bin/bash developer && \
    chown -R developer:developer /workspace && \
    chown -R developer:developer /app && \
    ln -sfn /workspace /home/developer/workspace && \
    ln -sfn /app /home/developer/app && \
    echo developer ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer

ENV USER=developer

ENV HOME /home/developer

ENV SHELL /bin/bash

USER $USER

WORKDIR /home/developer

# init rosdep
RUN rosdep fix-permissions && rosdep update

# colorize less
#RUN echo "export LESS='-R'" >> ~/.bash_profile && \
#    echo "export LESSOPEN='|pygmentize -g %s'" >> ~/.bash_profile

# enable bash completion
RUN echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc && \
    echo "source ~/.bashrc" >> ~/.bash_profile 

# install ydlidar_sdk first
RUN cd ~ && \
    git clone https://github.com/YDLIDAR/YDLidar-SDK.git && \
    mkdir -p YDLidar-SDK/build && \
    cd YDLidar-SDK/build && \
    cmake .. && \
    sudo make install && \
    rm -rf ~/YDLidar-SDK && \
    echo "DONE"

# compile turtlebot2 packages from sources
#COPY ./app/install/turtlebot2.sh /

RUN sudo apt-get update && sudo apt-get upgrade -y

RUN mkdir -p $HOME/dev_ws/src && \
    #bash /turtlebot2.sh && \
    #sudo rm -f /turtlebot2.sh && \
    cd $HOME/dev_ws/src && \
    git clone https://github.com/kobuki-base/kobuki_ros_interfaces.git && \
    git clone https://github.com/YDLIDAR/ydlidar_ros2_driver.git && \
    git clone https://github.com/wn1980/turtlebot2_ros2.git && \
    git clone https://github.com/michieletto/kobuki_ros.git && \
	mv kobuki_ros/kobuki_description ./ && \
	rm -rf kobuki_ros && \
    cd $HOME/dev_ws && \
    sudo rosdep install -i --from-path src --rosdistro galactic -y && \
    source /opt/ros/${ROS_DISTRO}/setup.bash && \
    colcon build --symlink-install && \
    echo "DONE"

# https://superuser.com/questions/555310/bash-save-history-without-exit
RUN echo "export PROMPT_COMMAND='history -a'" >> ~/.bashrc && \ 
    echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc && \
    echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc && \
    echo "source $HOME/dev_ws/install/setup.bash" >> ~/.bashrc && \
    echo "export TURTLEBOT_BASE=kobuki" >> ~/.bashrc && \
    echo "export TURTLEBOT_3D_SENSOR=asus_xtion_pro" >> ~/.bashrc && \
    echo "export TURTLEBOT_MAP_FILE=~/workspace/maps/map.yaml" >> ~/.bashrc

VOLUME /tmp/.X11-unix

COPY ./app /app

RUN sudo chown -R developer:developer /app

ENV DISPLAY ":1"

EXPOSE 8008 6901

CMD ["sudo", "-E", "/usr/local/bin/supervisord", "-c", "/app/supervisord.conf"]
