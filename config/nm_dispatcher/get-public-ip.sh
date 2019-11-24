#!/bin/bash

# Check if the dispatcher action is the right one.
# Let the network connection settle.
sleep 5

# Get the new public ip address.
# ip=$(dig +short myip.opendns.com @resolver1.opendns.com)  # <-- Using DNS (faster, but could be blocked)
ip=$(curl 'http://ipecho.net/plain')  # <-- Using HTTP (slower, but not blocked)

# Check if it ran successfully.
[[ "$?" -ne 0 ]] && ip="-"

# Write the ip to a file.
echo "$ip" > /run/publicip
