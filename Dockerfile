FROM ubuntu:trusty-20160317

# configuration
ENV _LOCALE=en_US.UTF-8
ENV _NVIDIA_VERSION=352
ENV _USER=unreal
ENV _USER_GROUPS=audio,video
ENV _USER_ID=1000

ENV _UNREAL_DATA_DIR=/opt/UnrealEngine
ENV _UNREAL_HOME_DIR=/home/${_USER}

ENV DEBIAN_FRONTEND noninteractive

# set locale
RUN locale-gen ${_LOCALE} \
  && update-locale LANG=${_LOCALE} LC_ALL=${_LOCALE}

# xorg-edgers/ppa     -- nvidia drivers
# multiverse          -- nvidia-cg and others
# x11-xserver-utils   -- provides /usr/bin/xrandr which is needed to start UE4Editor
# other packages will be installed by UnrealEngine/Setup.sh
RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:xorg-edgers/ppa \
    && add-apt-repository -y multiverse \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        libcuda1-${_NVIDIA_VERSION} \
        nvidia-${_NVIDIA_VERSION} \
        nvidia-cg-toolkit \
        nvidia-libopencl1-${_NVIDIA_VERSION} \
        nvidia-opencl-icd-${_NVIDIA_VERSION} \
        x11-xserver-utils \
        xdg-user-dirs \
    && apt-get install -y \
        mono-xbuild \
        mono-dmcs \
        libmono-microsoft-build-tasks-v4.0-4.0-cil \
        libmono-system-data-datasetextensions4.0-cil \
        libmono-system-web-extensions4.0-cil \
        libmono-system-management4.0-cil \
        libmono-system-xml-linq4.0-cil \
        libmono-corlib4.0-cil \
        libmono-windowsbase4.0-cil \
        libmono-system-io-compression4.0-cil \
        libmono-system-io-compression-filesystem4.0-cil \
        clang-3.5 \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

# UE4 will not compile as root user
# create new user, grant sudo access
RUN useradd -m -s /bin/bash -u ${_USER_ID} -G ${_USER_GROUPS} ${_USER} \
  && echo "${_USER}:${_USER}" | chpasswd \
  && echo "${_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${_USER} \
  && chmod 0440 /etc/sudoers.d/${_USER}

# switch to user
ENV HOME=/home/${_USER} USER=${_USER} LC_ALL=${_LOCALE} LANG=${_LOCALE}
USER ${_USER}
WORKDIR /home/${_USER}

VOLUME ["${_UNREAL_DATA_DIR}"]
VOLUME ["${_UNREAL_HOME_DIR}"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
