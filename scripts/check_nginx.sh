#!/bin/bash

if systemctl is-active --quiet nginx; then
    echo "Nginx: RUNNING"
else
    echo "Nginx: NOT RUNNING"
    exit 1
fi

if curl -fsS http://localhost > /dev/null; then
    echo "HTTP: OK"
else
    echo "HTTP: FAILED"
    exit 1
fi
