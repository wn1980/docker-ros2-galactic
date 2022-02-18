#!/usr/bin/env bash

set -e

rm -f /tmp/.X11-unix/X9
rm -f /tmp/.X9-lock

Xvnc :9 -depth 24 -ac -pn -rfbport=5901 -SecurityTypes=None -desktop=RobotOps
