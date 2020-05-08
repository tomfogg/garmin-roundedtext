#!/bin/sh 

docker kill garmin-roundwatch 
docker rm garmin-roundwatch
docker build -t garmin-roundwatch .
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
docker run -d --name garmin-roundwatch -e DISPLAY=:0 -v $XSOCK:$XSOCK -e XAUTHORITY=$XAUTH garmin-roundwatch
xauth nlist :0 | sed -e 's/^..../ffff/' | docker exec -i garmin-roundwatch sh -c "xauth -f $XAUTH nmerge -"
