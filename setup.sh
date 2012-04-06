#!/bin/bash

sudo apt-get install \
libenv-path-perl \
libfile-sharedir-perl \
libio-pty-perl \
libio-stty-perl \
liblist-moreutils-perl \
libregexp-common-perl \
libc6-dev \
make \


#libextutils-makemaker-perl \
#libio-handle-perl \
#libterm-ansicolor-perl\

make
sudo make install
