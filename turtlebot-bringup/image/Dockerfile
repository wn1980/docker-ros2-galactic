FROM ros:galactic-ros-core-focal

LABEL maintainer="Waipot Ngamsaad <waipotn@hotmail.com>"

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN sed -i -e 's/http:\/\/archive/mirror:\/\/mirrors/' -e 's/http:\/\/security/mirror:\/\/mirrors/' -e 's/\/ubuntu\//\/mirrors.txt/' /etc/apt/sources.list

RUN apt-get update --fix-missing && apt-get upgrade -y --fix-missing
RUN apt-get install -y \ 
	git \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /ros2_ws/src && \
	cd /ros2_ws/src && \
	#catkin_create_pkg docking std_msgs rospy && \
	echo "DONE"

RUN cd /ros2_ws/src && \
  git clone https://github.com/stonier/sophus.git -b release/1.2.x && \
  git clone https://github.com/stonier/ecl_core.git -b release/1.2.x && \
  git clone https://github.com/stonier/ecl_lite.git -b release/1.1.x && \
  git clone https://github.com/stonier/ecl_tools.git -b release/1.0.x && \
  echo "DONE"

RUN cd /ros2_ws/src && \
	git clone https://github.com/kobuki-base/kobuki_core.git && \
	git clone https://github.com/kobuki-base/kobuki_ros_interfaces.git && \
  	git clone https://github.com/kobuki-base/velocity_smoother.git && \
	git clone https://github.com/kobuki-base/cmd_vel_mux.git && \
	echo "DONE"

RUN cd /ros2_ws/src && \
	git clone https://github.com/kobuki-base/kobuki_ros.git && \
	mv kobuki_ros/kobuki_node kobuki_ros/kobuki_keyop kobuki_ros/kobuki_safety_controller \
	   kobuki_ros/kobuki_bumper2pc kobuki_ros/kobuki_auto_docking \
	   kobuki_ros/kobuki_description ./ && \
	rm -rf kobuki_ros

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y \ 
	build-essential \
	python3-rosdep \
	python3-colcon-common-extensions

RUN rosdep init && rosdep update

RUN cd /ros2_ws && \
	source /opt/ros/${ROS_DISTRO}/setup.bash && \
	rosdep install -i --from-path src --rosdistro galactic -y && \
	colcon build --symlink-install && \
	echo "DONE"

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install -y \ 
	ros-${ROS_DISTRO}-robot-state-publisher \
	ros-${ROS_DISTRO}-joint-state-publisher

# add turtlebot2_ros2_bringup package
COPY ./turtlebot2_ros2_bringup /ros2_ws/src/turtlebot2_ros2_bringup

RUN cd /ros2_ws && \
	source /opt/ros/${ROS_DISTRO}/setup.bash && \
	colcon build --packages-select turtlebot2_ros2_bringup && \
	echo "DONE"

# Finally, clean
RUN apt-get purge -y \ 
	git \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

CMD source /ros2_ws/install/setup.bash && ros2 launch turtlebot2_ros2_bringup bringup.launch.py
