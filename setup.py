#!/usr/bin/env python

import os,subprocess as sub

sub.call(['perl','Makefile.PL'])
sub.call(['make'])
sub.call(['sudo','make','install'])
