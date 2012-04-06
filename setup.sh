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

perl Makefile.PL

make
sudo make install

mkdir -p ~/.bash
echo "export PATH=$(perl cope_path.pl):\$PATH" >> ~/.bash/cope
