#!/usr/bin/env bash

set -e

sudo apt-get install git -y

TURTLEBOT_WS=$HOME/dev_ws

if [ ! -d $TURTLEBOT_WS/src/kobuki_ros ]; then

  mkdir -p $TURTLEBOT_WS/src

  cd $TURTLEBOT_WS/src

  git clone https://github.com/stonier/sophus.git -b release/1.2.x
  git clone https://github.com/stonier/ecl_core.git -b release/1.2.x
  git clone https://github.com/stonier/ecl_lite.git -b release/1.1.x
  git clone https://github.com/stonier/ecl_tools.git -b release/1.0.x

  git clone https://github.com/kobuki-base/kobuki_core.git
  git clone https://github.com/kobuki-base/kobuki_ros_interfaces.git
  git clone https://github.com/kobuki-base/velocity_smoother.git
  git clone https://github.com/kobuki-base/cmd_vel_mux.git

  git clone https://github.com/kobuki-base/kobuki_ros.git && \
	mv kobuki_ros/kobuki_node kobuki_ros/kobuki_keyop kobuki_ros/kobuki_safety_controller kobuki_ros/kobuki_bumper2pc ./ && \
	rm -rf kobuki_ros

  git clone https://github.com/michieletto/kobuki_ros.git && \
	mv kobuki_ros/kobuki_description ./ && \
	rm -rf kobuki_ros

	git clone https://github.com/wn1980/kobuki_ros.git && \
	mv kobuki_ros/kobuki_auto_docking ./ && \
	rm -rf kobuki_ros
  
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

sudo rosdep install -i --from-path src --rosdistro galactic -y
  
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
