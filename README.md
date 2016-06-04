Dockerized Unreal Engine 4
==========================

## NOTE
* docker image is small, and volume uses about 25GB of disk space initially
* builds in ~1.5 hours depending on network and hardware

## Installation
1. signup with Epic Games for access to UnrealEngine4 github repository

2. download .tar.gz file or "git clone" desired version of UnrealEngine from github

3. edit Dockerfile
   * set \_NVIDIA\_VERSION to match the nvidia binary version of the host OS
   * optionally, set \_USER\_ID to match the userid on the host OS that you want to own created files

4. build
```bash
docker build -t unrealengine:latest .
```

5. run; mount volumes for the UnrealEngine source code from github and a home directory (to perserve your projects)
```bash
./xlaunch -v /home/myuser/UnrealEngineSource:/opt/UnrealEngine -v /home/myuser/UnrealEngineHome:/home/unreal/ unrealengine:latest
```
