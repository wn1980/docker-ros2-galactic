#!/usr/bin/env bash

set -e

#sudo apt-get update
#sudo apt-get install -y \
#  git \
#  ros-galactic-ecl-core \
#  ros-galactic-ecl-lite \
#  ros-galactic-ecl-tools \
#  ros-galactic-sophus

PY_TREES_WS=$HOME/dev_ws

if [ ! -d $PY_TREES_WS/src/py_trees_ros ]; then

  mkdir -p $PY_TREES_WS/src

  cd $PY_TREES_WS/src

  git clone https://github.com/splintered-reality/py_trees.git -b release/2.1.x
  git clone https://github.com/splintered-reality/py_trees_ros.git -b release/2.1.x
  git clone https://github.com/splintered-reality/py_trees_ros_interfaces.git -b release/2.0.x
  git clone https://github.com/splintered-reality/py_trees_ros_tutorials.git -b release/2.1.x
  git clone https://github.com/splintered-reality/py_trees_js.git
  git clone https://github.com/splintered-reality/py_trees_ros_viewer.git

  git clone https://github.com/BehaviorTree/Groot.git

fi

sudo apt-get update && sudo apt-get upgrade -y 

# make and install
cd $PY_TREES_WS

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
