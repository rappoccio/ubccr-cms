docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v ${PWD}:/results --rm -it --entrypoint /bin/bash  $1
