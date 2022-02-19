FROM ros:galactic-ros-core-focal
#FROM ros:foxy-ros-core-focal
#FROM ros:dashing-ros-core-bionic

LABEL maintainer="Waipot Ngamsaad <waipotn@hotmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

RUN apt-get update --fix-missing && apt-get upgrade -y
RUN	apt-get install -y \ 
	build-essential \
	libboost-all-dev \
	ros-${ROS_DISTRO}-depthimage-to-laserscan \
	ros-${ROS_DISTRO}-image-transport-plugins \
	git \
	python3-rosdep \
	python3-colcon-common-extensions

RUN rosdep init && rosdep update

RUN mkdir -p /ros2_ws/src && \
	cd /ros2_ws/src && \
	#catkin_create_pkg docking std_msgs rospy && \
	echo "DONE"

RUN cd /ros2_ws/src && \
	git clone https://github.com/mikeferguson/openni2_camera.git

RUN cd /ros2_ws && \
	source /opt/ros/${ROS_DISTRO}/setup.bash && \
	rosdep install -i --from-path src --rosdistro galactic -y && \
	colcon build --symlink-install && \
	echo "DONE"

#COPY ./sensor3d.launch /

# Finally, clean
RUN	apt-get purge -y \ 
	git \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

CMD source /ros2_ws/install/setup.bash && ros2 launch openni2_camera camera_only.launch.py
