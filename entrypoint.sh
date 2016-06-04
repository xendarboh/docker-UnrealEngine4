#!/bin/bash

# abort if UnrealEngine source code not found
sudo test ! -f ${_UNREAL_DATA_DIR}/Setup.sh \
    && echo "UnrealEngine source code not found in ${_UNREAL_DATA_DIR}" \
    && exit 1

# build if not already built
sudo test ! -f ${_UNREAL_DATA_DIR}/Engine/Binaries/Linux/UE4Editor \
    && echo "Building... takes a while" \
    && sudo chown -R ${_USER}:${_USER} ${_UNREAL_DATA_DIR} \
    && cd ${_UNREAL_DATA_DIR} \
    && ./Setup.sh \
    && ./GenerateProjectFiles.sh \
    && make \
    && make BlankProgram \
    && make SlateViewer \
    && make UE4Client \
    && make UE4Game \
    && make UE4Server \
    && echo "Finished building"

# initialize user home directory, if not already
sudo test ! -f ${_UNREAL_HOME_DIR}/.bashrc \
    && sudo chown -R ${_USER}:${_USER} ${_UNREAL_HOME_DIR} \
    && cp /etc/skel/.bashrc  ${_UNREAL_HOME_DIR}/.bashrc \
    && cp /etc/skel/.profile ${_UNREAL_HOME_DIR}/.profile \
    && echo "Initialized home directory"

# install plugin: vim/emacs editor
cd ${_UNREAL_DATA_DIR}/Engine/Plugins/Developer \
    && test ! -d SensibleEditorSourceCodeAccess \
    && git clone https://github.com/fire/SensibleEditorSourceCodeAccess \
    && cd - \
    && mono Engine/Binaries/DotNET/UnrealBuildTool.exe Linux Development UE4Editor -module SensibleEditorSourceCodeAccess

# enter the binaries directory
cd ${_UNREAL_DATA_DIR}/Engine/Binaries/Linux

# start a shell by default because UE4Editor launched here fails to start projects
if [[ -z ${1} ]]
then
    exec /bin/bash
else
    exec ${@}
fi
