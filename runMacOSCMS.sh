docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v ${PWD}:/home/jovyan/results -v ~/.globus:/home/jovyan/.globus -p $1:8888 --rm -it --user jovyan --entrypoint /bin/bash  $2
