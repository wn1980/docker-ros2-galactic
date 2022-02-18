import os
import yaml

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch_ros.actions import Node, ComposableNodeContainer
from launch_ros.descriptions import ComposableNode
from launch_ros.substitutions import FindPackageShare
from launch.substitutions import LaunchConfiguration, Command, PathJoinSubstitution, EnvironmentVariable
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, ExecuteProcess
from launch.launch_description_sources import PythonLaunchDescriptionSource

def generate_launch_description():
    # package root
    share_dir = get_package_share_directory('turtlebot2_ros2_bringup')

    # kobuki_ros node
    params_file = os.path.join(share_dir, 'config/kobuki', 'kobuki_node_params.yaml')
    
    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)['kobuki_ros_node']['ros__parameters']

    kobuki_node = ComposableNode(
        package='kobuki_node',
        plugin='kobuki_node::KobukiRos',
        name='kobuki_ros_node',
        namespace='mobile_base',
        parameters=[params],
        remappings=[
            ('odom', '/odom'),
            ('joint_states', '/joint_states')
        ],
    )

    # kobuki_safety_controller
    params_file = os.path.join(share_dir, 'config/kobuki', 'safety_controller_params.yaml')

    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)['kobuki_safety_controller_node']['ros__parameters']

    safety_controller_node = ComposableNode(
        package='kobuki_safety_controller',
        plugin='kobuki_safety_controller::SafetyController',
        name='kobuki_safety_controller_node',
        namespace='mobile_base',
        parameters=[params],
        remappings=[
            ('cmd_vel', '/cmd_vel_mux/input/safety_controller')
        ],
    )

    # kobuki_auto_docking
    params_file = os.path.join(share_dir, 'config/kobuki', 'auto_docking.yaml')

    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)['kobuki_auto_docking']['ros__parameters']
    
    kobuki_auto_docking_node = ComposableNode(
        package='kobuki_auto_docking',
        plugin='kobuki_auto_docking::AutoDockingROS',
        name='kobuki_auto_docking_node',
        namespace='mobile_base',
        remappings=[
            ('commands/velocity', '/cmd_vel_mux/input/auto_docking'),
            ('odom', '/odom'),
        #    ('core', 'sensors/core'),
        #    ('dock_ir', 'sensors/dock_ir')
        ],
        parameters=[params]
    )

    # kobuki_bumper2pc
    params_file = os.path.join(share_dir, 'config/kobuki', 'kobuki_bumper2pc_params.yaml')

    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)['kobuki_bumper2pc']['ros__parameters']

    kobuki_bumper2pc_node = ComposableNode(
        package='kobuki_bumper2pc',
        plugin='kobuki_bumper2pc::Bumper2PcNode',
        name='kobuki_bumper2pc_node',
        namespace='mobile_base',
        parameters=[params],
        remappings=[
            ('core_sensors', 'sensors/core'),
            ('pointcloud', 'sensors/bumper_pointcloud')
        ],
    )

    # cmd_vel_mux
    params_file = os.path.join(share_dir, 'config', 'cmd_vel_mux_params.yaml')

    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)['cmd_vel_mux']['ros__parameters']

    cmd_vel_mux_node = ComposableNode(
        package='cmd_vel_mux',
        plugin='cmd_vel_mux::CmdVelMux',
        name='cmd_vel_mux_node',
        namespace='cmd_vel_mux',
        remappings=[
            ('cmd_vel', '/mobile_base/commands/velocity'),
            #('input/default', '/cmd_vel')
        ],
        parameters=[params]
    )

    # velocity_smoother
    params_file = os.path.join(share_dir, 'config', 'velocity_smoother_params.yaml')

    with open(params_file, 'r') as f:
        params = yaml.safe_load(f)['velocity_smoother']['ros__parameters']
    
    velocity_smoother_default_node = ComposableNode(
        package='velocity_smoother',
        plugin='velocity_smoother::VelocitySmoother',
        name='velocity_smoother_default',
        remappings=[
            ('velocity_smoother_default/smoothed', '/cmd_vel_mux/input/default'),
            ('velocity_smoother_default/feedback/cmd_vel', '/mobile_base/commands/velocity'),
            ('velocity_smoother_default/feedback/odometry', '/odom'),
            ('velocity_smoother_default/input', '/cmd_vel')
        ],
        parameters=[params]
    )

    # packs to the container
    mobile_base_container = ComposableNodeContainer(
            package='rclcpp_components',
            executable='component_container',
            name='mobile_base_container',
            namespace='',
            composable_node_descriptions=[
                kobuki_node,
                safety_controller_node,
                cmd_vel_mux_node,
                kobuki_auto_docking_node,
                kobuki_bumper2pc_node,
                velocity_smoother_default_node
            ],
            output='both',
    )

    # robot_description
    description_launch_path = PathJoinSubstitution(
        [FindPackageShare('turtlebot2_ros2_bringup'), 'launch', 'description.launch.py']
    )

    robot_description = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(description_launch_path)
    )

    # Finally, return all nodes
    return LaunchDescription([
        robot_description,
        mobile_base_container,

        Node(
            package='turtlebot2_ros2_bringup',
            executable='activation_button.py',
            name='activation_button_node',
            output='screen'
        ),
    ])
