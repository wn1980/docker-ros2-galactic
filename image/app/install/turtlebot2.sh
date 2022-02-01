#!/usr/bin/env bash
# Based on: https://github.com/gaunthan/Turtlebot2-On-Melodic

set -e

sudo apt-get install git -y

TURTLEBOT_WS=$HOME/dev_ws

if [ ! -d $TURTLEBOT_WS/src/kobuki_ros ]; then

  mkdir -p $TURTLEBOT_WS/src

  cd $TURTLEBOT_WS/src

  #git clone https://github.com/turtlebot/turtlebot.git
  #git clone https://github.com/turtlebot/turtlebot_msgs.git
  #git clone https://github.com/turtlebot/turtlebot_apps.git
  #git clone https://github.com/turtlebot/turtlebot_simulator.git
  #git clone https://github.com/turtlebot/turtlebot_viz.git

  git clone https://github.com/kobuki-base/kobuki_ros.git
  git clone https://github.com/kobuki-base/kobuki_ros_interfaces.git
  git clone https://github.com/kobuki-base/velocity_smoother.git
  git clone https://github.com/kobuki-base/cmd_vel_mux.git

  # Additionals
  git clone https://github.com/YDLIDAR/ydlidar_ros2_driver.git
  git clone https://github.com/wn1980/turtlebot2_ros2.git

fi

sudo apt-get update && sudo apt-get upgrade -y 

# install ydlidar_sdk first
cd ~
git clone https://github.com/YDLIDAR/YDLidar-SDK.git 
mkdir -p YDLidar-SDK/build
cd YDLidar-SDK/build
cmake ..
sudo make install
rm -rf ~/YDLidar-SDK

# make and install
cd $TURTLEBOT_WS

sudo rosdep install -i --from-path src --rosdistro foxy -y
  
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
