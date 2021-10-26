Collage.md

# Collage

## ideas and definitions of words taken around random reads of forth groups

"May the Forth be with you."

---

> ## http://computer-programming-forum.com/22-forth/fc123450c480e39c.htm Ulrich Hoffmann,
```
\ DEFER and IS -------------------------------------------------------

: crash ( -- )  TRUE ABORT" uninitialized execution vector" ;

: DEFER ( x <spaces>name -- )
   CREATE  ['] crash ,

: IS \ Interpretation: ( x <spaces>name -- )
     \ Compilation:    ( <spaces>name -- )
  ' >BODY  

  ! ; IMMEDIATE

\ --------------------------------------------------------------------
```
P.S. For even more ANSI compatibility you can use the ANSI-CORE&CORE-EXT layer for F-PC (http://www.informatik.uni-kiel.de/~uho/ansi.seq).

---
> ## excerpts from "Programming a problem-oriented language", Charles H. Moore, june/1970, updated 2011

    Input is information that controls a program.
    
    Nouns place arguments onto the stack.
    Verbs operate upon arguments on the stack.

    Unary verbs modify the number on the stack.
    Binary verbs combine 2 arguments to leave a single result.

    Destructive verb removes its arguments from the stack.
    Non-destructive verb leaves its arguments on the stack.

    Constants place the contents of their parameter field onto the stack.
    Variables place the address of their parameter field onto the stack.
    
    To name a location from which a value is to be taken.
    To name a location into which a value is to be stored.

    1: execute, 0: compile, applying both to switch and flag. 
   
    For a given entry, 'or' the switch and flag together; if either is 1, execute the word, else compile it.


---
> ## https://home.hccnet.nl/a.w.m.van.der.horst/forthlecture5.html Albert van der Horst

- An annihilator is a word that only deletes an item from the stack.
Examples are DROP 2DROP NIP RDROP.

- A juggler reorders the stack without adding or removing items.
Examples are SWAP 2SWAP ROT.

- A duplicator copies an item from the stack.  Examples are DUP OVER
2DUP.

- (my) Also: A generator puts an item into stack
---
