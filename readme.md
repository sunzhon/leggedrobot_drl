# How to do

This repository provides some scripts to setup ambot environment in a docker container.



## Load an image from the docker hub
**If you have not installed docker, you can run install.sh in this folder to install docker and run docker execution automatically.**
e.g., 
```
sudo sh ./install.sh
```

## Build a docker image from scratch
**If you have installed docker on your system. There are two ways to get docker images for the development container.**

### 1. Pull image from the docker hub

*Note: sunzhon/ambot_env:0.52 is only for single leg control, if you wanna an env for controlling the whole robot, please contact suntao.hn@gmail.com*
docker image pull sunzhon/ambot_env:0.52
docker run -u root -it --name ambot -v /dev/:/dev/ --privileged sunzhon/ambot_env:0.52 /bin/bash


### 2. Build an image using docker file. Run the following command to generate an image of the Ambot development env

docker build --progress=plain -t sunzhon/ambot_env:0.51 --build-arg user=$USER -f ./Dockerfile --network host  .

[ docker run -u ${USER} -it -v /dev/:/dev/ --privileged sunzhon/ambot_env:0.51 /bin/bash ] && docker run -u suntao -it -v /dev/:/dev/ --privileged sunzhon/ambot_env:0.51 /bin/bash


## Tips of using docker 

- open a terminal of the execution container: docker exec -it ambot /bin/bash
- copy file between host and container: docker cp source_file target_file target_file, e.g., docker cp /home/file ambot:/home/
- docker run -it image /bin/bash
