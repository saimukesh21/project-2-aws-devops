#!/bin/bash

THRESHOLD=80
USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

echo "Root filesystem usage: ${USAGE}%"

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage is above ${THRESHOLD}%"
    exit 1
else
    echo "Disk usage: OK"
fi
