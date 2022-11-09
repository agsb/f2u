#/usr/bin/bash

case $1 in
    x)  
    make clean ; rm err out ; 
    ;;
    c)
    make clean ; make 2> err 1> out
    ;;
esac

grep HEADER *.S > words
