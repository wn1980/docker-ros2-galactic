#!/usr/bin/env bash

set -e

sudo apt update && sudo apt-get install -y git

ROS_WS=$HOME/dev_ws

if [ ! -d $ROS_WS/src/kobuki_ros ]; then

  mkdir -p $ROS_WS/src

  cd $ROS_WS/src

  # tested on hunble
  git clone https://github.com/stonier/sophus.git -b 1.3.1
  git clone https://github.com/stonier/ecl_tools.git -b 1.0.3
  git clone https://github.com/stonier/ecl_core.git -b 1.2.1
  git clone https://github.com/stonier/ecl_lite.git -b 1.2.0

  git clone https://github.com/kobuki-base/kobuki_ros_interfaces.git

fi

sudo apt-get update #&& sudo apt-get upgrade -y 

# make and install
cd $ROS_WS

sudo rosdep install -i --from-path src --rosdistro humble -y
  
source /opt/ros/${ROS_DISTRO}/setup.bash

colcon build --symlink-install

# Install additionals and clean
sudo apt-get install  -y \
  #ros-${ROS_DISTRO}-kobuki-core \
  #ros-${ROS_DISTRO}-kobuki-ftdi \
  #ros-${ROS_DISTRO}-kobuki-firmware \
  man \
  && sudo apt-get autoremove -y \
  && sudo apt-get clean \
  && sudo rm -rf /var/lib/apt/lists/*
