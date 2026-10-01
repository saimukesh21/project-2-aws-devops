#!/bin/bash

echo "===== Project 2 System Information ====="
echo "Hostname: $(hostname)"
echo "OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo "Memory:"
free -h
echo "Disk:"
df -h /
