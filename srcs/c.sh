#/usr/bin/bash

make clean ; make 2> err 1> out
grep HEADER *.S > words
