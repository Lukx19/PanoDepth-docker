#!/bin/bash

XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

gpus='0,1'
if [ -n "$1" ]; then
    gpus="$1"
fi

docker run -it \
         --runtime=nvidia \
        -e NVIDIA_VISIBLE_DEVICES=$gpus \
        --shm-size 8G \
        --env="DISPLAY=$DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --env="XAUTHORITY=$XAUTH" \
        --volume="$XAUTH:$XAUTH" \
        -e USER_N=$(id -un) \
        --volume="/etc/group:/etc/group:ro" \
        --volume="/etc/passwd:/etc/passwd:ro" \
        --volume="/etc/shadow:/etc/shadow:ro" \
        --volume="/home/$USER/workspace:/workspace/" \
        --workdir="/workspace/" \
        -p 8888:8097 \
        --name panodepth \
        --rm \
        lukx19/panodepth:latest \
        /bin/bash

        # --user=$(id -u):$(id -g) \