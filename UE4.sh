#!/bin/bash
UNREAL_DATA_DIR=/srv/UnrealEngine/UnrealEngine-4.11.2-release
UNREAL_HOME_DIR=/srv/UnrealEngine/home

_PWD="$(readlink -f $(dirname $0))"
${_PWD}/xlaunch.sh --rm \
    -v ${UNREAL_DATA_DIR}:/opt/UnrealEngine \
    -v ${UNREAL_HOME_DIR}:/home/unreal \
    unrealengine:latest \
    ${@}
