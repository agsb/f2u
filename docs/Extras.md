# Extras

<< this file is still a stub >>

## EXEC TAIL EXIT

There are some words that exchanges values between stacks and instruction pointer, usualy 

RP@, SP@, IP@

- rpush: 
- rpull:
- spush:
- spull:

- : lit R> DUP 2 + >R @ ;

- : exec >R ;

- : tail R@ 2 - >R ;

- : exit ???


## DEFER and IS

\ DEFER and IS -------------------------------------------------------

: crash ( -- )  TRUE ABORT" uninitialized execution vector" ;

: DEFER ( x <spaces>name -- )
   CREATE  ['] crash ,

: IS \ Interpretation: ( x <spaces>name -- )
     \ Compilation:    ( <spaces>name -- )
  ' >BODY  

  ! ; IMMEDIATE

\ --------------------------------------------------------------------

Ulrich 
