#!/bin/bash

errors=$(bash depends.sh)
error=$?
#echo $errors

if [ $error -eq 0 ];then
    perl Makefile.PL
    make
else
    echo missing packages: $errors
    echo try: sudo apt-get install $errors
fi
