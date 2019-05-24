docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v ${PWD}:/home/centos/results --rm -it --user centos --entrypoint /bin/bash  $1
