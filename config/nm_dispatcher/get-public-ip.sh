#!/bin/bash

# Check if the dispatcher action is the right one.
#if [[ "$NM_DISPATCHER_ACTION" == "connectivity-change" ]]; then
    # Let the network connection settle.
    sleep 1

    # Get the new public ip address.
    # ip=$(dig +short myip.opendns.com @resolver1.opendns.com)  # <-- Using DNS (faster, but could be blocked)
    ip=$(curl 'http://ipecho.net/plain')  # <-- Using HTTP (slower, but not blocked)

    # Check if it ran successfully.
    [[ "$?" -ne 0 ]] && ip="-"

    # Write the ip to a file.
    echo "$ip" > /run/publicip
#fi
