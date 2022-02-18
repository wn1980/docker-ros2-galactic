#!/usr/bin/env python3

import rclpy

from rclpy.action import ActionClient
from rclpy.node import Node
from kobuki_ros_interfaces.action import AutoDocking

class AutoDockingActionClient(Node):

    def __init__(self):
        super().__init__('auto_docking_action_client')
        self._action_client = ActionClient(self, AutoDocking, '/mobile_base/auto_docking_action')

        self.DONE = False

    def send_goal(self):
        goal_msg = AutoDocking.Goal()

        self._action_client.wait_for_server()

        self._send_goal_future = self._action_client.send_goal_async(
            goal_msg, \
            feedback_callback=self.feedback_callback
        )

        self._send_goal_future.add_done_callback(self.goal_response_callback)

        self.get_logger().info('Sent Goal!')

    def goal_response_callback(self, future):
        goal_handle = future.result()

        if not goal_handle.accepted:
            self.get_logger().info('Goal rejected :(')
            return

        self.get_logger().info('Goal accepted :)')

        self._get_result_future = goal_handle.get_result_async()
        self._get_result_future.add_done_callback(self.get_result_callback)

    def get_result_callback(self, future):
        result = future.result().result
        self.get_logger().info('Result: {0}'.format(result.text))
        self.DONE = True
        
    def feedback_callback(self, feedback_msg):
        feedback = feedback_msg.feedback
        self.get_logger().info('Received feedback: \n state: {0} \n text: {1}'.format(feedback.state, feedback.text))

def main(args=None):
    rclpy.init(args=None)

    action_client = AutoDockingActionClient()

    action_client.send_goal()

    try:
        while not action_client.DONE:
            rclpy.spin_once(action_client)
    except KeyboardInterrupt:
        pass

    rclpy.shutdown()

if __name__ == '__main__':
    main()
