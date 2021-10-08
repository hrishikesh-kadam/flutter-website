#!/usr/bin/env bash

# Bash script to add the host user in the Docker user-base image to avoid file 
# ownership issues on the host side.
# Dependent on the .env file generated using `make genenv`.
# Usage - To be executed inside the Docker image.

declare -a KERNELS=(Linux Darwin)

for KERNEL in ${KERNELS[@]}; do
  if [[ $KERNEL == $HOST_KERNEL_NAME ]]; then
    if [[ -n $HOST_GROUP_ID && -n $HOST_GROUP_NAME && -n $HOST_USER_ID \
    && -n $HOST_USER_HOME && -n $HOST_USER_NAME ]]; then
      groupadd -g $HOST_GROUP_ID $HOST_GROUP_NAME
      mkdir -p $HOST_USER_HOME
      useradd -u $HOST_USER_ID \
        -g $HOST_GROUP_NAME \
        -d $HOST_USER_HOME \
        $HOST_USER_NAME
      chown $HOST_USER_ID:$HOST_GROUP_ID $HOST_USER_HOME
      usermod -aG sudo $HOST_USER_NAME
      echo "$HOST_USER_NAME ALL=NOPASSWD: ALL" > \
        /etc/sudoers.d/$HOST_USER_NAME-nopasswd
    fi
    break
  fi
done
