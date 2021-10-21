Collage.md

# definitions of words taken around random reads of forth groups

> 
http://computer-programming-forum.com/22-forth/fc123450c480e39c.htm
Ulrich Hoffmann,

\ DEFER and IS -------------------------------------------------------

: crash ( -- )  TRUE ABORT" uninitialized execution vector" ;

: DEFER ( x <spaces>name -- )
   CREATE  ['] crash ,

: IS \ Interpretation: ( x <spaces>name -- )
     \ Compilation:    ( <spaces>name -- )
  ' >BODY  

  ! ; IMMEDIATE

\ --------------------------------------------------------------------

P.S. For even more ANSI compatibility you can use the ANSI-CORE&CORE-EXT
layer for F-PC (http://www.informatik.uni-kiel.de/~uho/ansi.seq).


> https://home.hccnet.nl/a.w.m.van.der.horst/forthlecture5.html

   - An annihilator is a word that only deletes an item from the stack.
Examples are DROP 2DROP NIP RDROP.

   - A juggler reorders the stack without adding or removing items.
Examples are SWAP 2SWAP ROT.

   - A duplicator copies an item from the stack.  Examples are DUP OVER
2DUP.
