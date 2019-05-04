#!/bin/bash

# Read the public ip.
ip=$(cat /run/publicip || "-")

# Write the public ip to stdout.
echo "  $ip"
