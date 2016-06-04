#!/bin/bash

# This script may be used to launch a docker container with docker options that:
#   * enable running X applications inside the container if the host has an
#     active X-windows session
#   * map certain devices if present on the host
#   * map volumes

test -z "$1" && echo "USAGE: $0 (docker opts) <docker image> (command)" && exit 1

####################################
# XAUTH
####################################
# enable xauth if the host appears to have active X session
# reference: http://stackoverflow.com/questions/91368/checking-from-shell-script-if-a-directory-contains-files
if (test ! -d /tmp/.X11-unix || (find /tmp/.X11-unix/ -maxdepth 0 -empty | read v))
then
    echo "$0: not enabling xauth"
else
    echo "$0: enabling xauth"
    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    touch $XAUTH
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
    chmod 644 $XAUTH
    _OPTS_XAUTH="
        -e DISPLAY=$DISPLAY \
        -e XAUTHORITY=$XAUTH \
        -v $XSOCK:$XSOCK:rw \
        -v $XAUTH:$XAUTH:rw \
    "
fi

####################################
# VOLUMES
####################################
_PWD="$(readlink -f $(dirname $0))"
_OPTS_VOLUMES="
"

####################################
# DEVICES
####################################
_OPTS_DEVICES=""
for x in \
    /dev/dri/card* \
    /dev/loop* \
    /dev/nvidia* \
    /dev/snd/seq \
    /dev/ttyUSB* \
    /dev/video*
do
    test -e $x && _OPTS_DEVICES="$_OPTS_DEVICES --device=$x:$x"
done

####################################
# CAPS
####################################
#_OPTS_CAPS="
#    --privileged
#    --cap-add SYS_ADMIN
#    --cap-add MKNOD
#"

####################################
# DOCKER RUN
####################################
docker run -it \
    ${_OPTS_CAPS} \
    ${_OPTS_XAUTH} \
    ${_OPTS_VOLUMES} \
    ${_OPTS_DEVICES} \
    $@
exit 0
