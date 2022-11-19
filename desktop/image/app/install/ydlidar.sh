#!/usr/bin/env bash

set -e

sudo apt update && sudo apt-get install -y \
  git

DEV_WS=$HOME/dev_ws

if [ ! -d $DEV_WS/src/ydlidar_ros2_driver ]; then

  mkdir -p $DEV_WS/src

  cd $DEV_WS/src

  git clone https://github.com/wn1980/ydlidar_ros2_driver.git

  # install ydlidar_sdk first
  cd ~
  git clone https://github.com/YDLIDAR/YDLidar-SDK.git 
  mkdir -p YDLidar-SDK/build
  cd YDLidar-SDK/build
  cmake ..
  sudo make install
  rm -rf ~/YDLidar-SDK

fi

sudo apt-get update #&& sudo apt-get upgrade -y 

# make and install
cd $DEV_WS

sudo rosdep install -i --from-path src --rosdistro humble -y
  
source /opt/ros/${ROS_DISTRO}/setup.bash

colcon build --symlink-install

# Install additionals and clean
sudo apt-get install -y \
  #ros-${ROS_DISTRO}-kobuki-core \
  #ros-${ROS_DISTRO}-kobuki-ftdi \
  #ros-${ROS_DISTRO}-kobuki-firmware \
  man \
  && sudo apt-get autoremove -y \
  && sudo apt-get clean \
  && sudo rm -rf /var/lib/apt/lists/*
