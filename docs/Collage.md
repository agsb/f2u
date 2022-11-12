Collage.md

# Collage

## ideas and definitions taken around random reads of forth groups

"May the Forth be with you."

---
## thread: minimal core version of forth? 

"You are looking for something that doesn't exist.  And if your
objective is just to build your own, you're _really_ violating
Chuck's philosophy, which is to keep the problem and its
solution in the forefront.  If you have no problem to solve,
you're just playing, so it doesn't matter where you start."

Elizabeth D. Rathe, Jun 2005
http://computer-programming-forum.com/22-forth/e05a013189430462.htm 

---
## muforth

A Forth virtual machine in C language, with basic primitives, full portable, and a Forth language in Forth.

> https://github.com/nimblemachines/muforth/blob/master/src/engine-itc.c
```
#define NEST      RPUSH((addr)IP)
#define UNNEST    (IP = (xt_cell *)RPOP)

/* The most important "word" of all: */
static void mu_do_colon()
{
    NEST;                       /* entering a new word; push IP */
    IP = (xt_cell *)&W[1];      /* new IP is address of parameter field */
}

/* The basis of create/does>. */
static void mu_do_does()
{
    NEST;                       /* entering a new word; push IP */
    IP = (xt_cell *)_(W[1]);    /* new IP is stored in the parameter field */
    PUSH_ADDR(&W[2]);           /* push the address of the word's body */
}

```
muForth also names primitives as *leafs*, routines without calls, or as *twigs*, routines as list of references, for Indirect thread code.

---
> Alvaro H. Salas, National University of Colomb

sin x = x - (x^3)/3! + (x^5)/5! - (x^7)/7!

cos x =  1 - (x^2)/2! + (x^4)/4! - (x^6)/6!

Chebyshev polynomials T1(x), T3(x), T5(x), T7(x). 

sin x ≈ 1.0001 * x − 0.166667 * x^3 + 0.00855974 * x^5 - 0.000204627 * x^7

Chebyshev polynomials T1(x), T2(x), T6(x), T7(x).

cos x = 1.0000 - 0.5000 * x^2 + 0.0416667 * x^4 - 0.00138875 * x^6

---

> ## exact div by 10, http://homepage.cs.uiowa.edu/~jones/bcd/divide.html

The final code given above also works in 32 bits with only one additional shift and add step:

	unsigned long int A;
	unsigned long int Q; /* the quotient */

	Q = ((A >>  1) + A) >> 1; /* Q = A*0.11 */
	Q = ((Q >>  4) + Q)     ; /* Q = A*0.110011 */
	Q = ((Q >>  8) + Q)     ; /* Q = A*0.11001100110011 */
	Q = ((Q >> 16) + Q) >> 3; /* Q = A*0.000110011001100110011001100110011 */
    /* either Q = A/10 or Q+1 = A/10 for all 32-bit unsigned A */

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
> ## In listing of "PDP-11 FORTH      RT-11, RSX-11M, AND STAND-ALONE      JANUARY 1980", by JOHN S. JAMES

## 1. Branch is offset not absolute
``` 
; 
        HEAD    206,BRANCH,240,BRAN                     ; ***** BRANCH
;  USED ONLY BY COMPILER.  FORTH BRANCH TO ADDRESS WHICH FOLLOWS.
        ADD     (IP),IP
        NEXT
````
## 2. Control words pairs are checked by values in stack. Simple and wise.
```
;
;  COMPILE-TIME SYNTAX-ERROR CHECKS.
;
        HEAD    206,?ERROR,240,QERR,DOCOL               ; ***** ?ERROR
        .WORD   SWAP,ZBRAN,XXN2-.,ERROR,BRAN,XXN3-.
XXN2:   .WORD   DROP
XXN3:   .WORD   SEMIS
;
        HEAD    205,?COMP,320,QCOMP,DOCOL               ; ***** ?COMP
        .WORD   STATE,AT,ZEQU,LIT,21,QERR,SEMIS
;
        HEAD    205,?EXEC,303,QEXEC,DOCOL               ; ***** ?EXEC
        .WORD   STATE,AT,LIT,22,QERR,SEMIS
;
        HEAD    206,?PAIRS,240,QPAIR,DOCOL              ; ***** ?PAIRS
        .WORD   SUB,LIT,23,QERR,SEMIS
;
        HEAD    204,BACK,240,BACK,DOCOL                 ; ***** BACK
        .WORD   HERE,SUB,COMMA,SEMIS
;
        HEAD    305,BEGIN,316,BEGIN,DOCOL               ; ***** BEGIN
        .WORD   QCOMP,HERE,ONE,SEMIS
;
        HEAD    305,ENDIF,306,ENDIF,DOCOL               ; ***** ENDIF
        .WORD   QCOMP,TWO,QPAIR,HERE,OVER,SUB,SWAP,STORE,SEMIS
;
        HEAD    304,THEN,240,THEN,DOCOL                 ; ***** THEN
        .WORD   ENDIF,SEMIS
;
        HEAD    302,DO,240,DO,DOCOL                     ; ***** DO
        .WORD   COMP,XDO,HERE,LIT,3,SEMIS
;
        HEAD    304,LOOP,240,LOOP,DOCOL                 ; ***** LOOP
        .WORD   LIT,3,QPAIR,COMP,XLOOP,BACK,SEMIS
;
        HEAD    305,+LOOP,320,PLOOP,DOCOL               ; ***** +LOOP
        .WORD   LIT,3,QPAIR,COMP,XPLOO,BACK,SEMIS
;
        HEAD    305,UNTIL,314,UNTIL,DOCOL               ; ***** UNTIL
        .WORD   ONE,QPAIR,COMP,ZBRAN,BACK,SEMIS
;
        HEAD    303,END,304,END,DOCOL                   ; ***** END
        .WORD   UNTIL,SEMIS
;
        HEAD    305,AGAIN,316,AGAIN,DOCOL               ; ***** AGAIN
        .WORD   ONE,QPAIR,COMP,BRAN,BACK,SEMIS
;
        HEAD    306,REPEAT,240,REPEAT,DOCOL             ; ***** REPEAT
        .WORD   TOR,TOR,AGAIN,FROMR,FROMR,TWO,SUB,ENDIF,SEMIS
;
        HEAD    302,IF,240,IF,DOCOL                     ; ***** IF
        .WORD   COMP,ZBRAN,HERE,ZERO,COMMA,TWO,SEMIS
;
        HEAD    304,ELSE,240,ELSE,DOCOL                 ; ***** ELSE
        .WORD   TWO,QPAIR,COMP,BRAN,HERE,ZERO,COMMA
        .WORD   SWAP,TWO,ENDIF,TWO,SEMIS
;
        HEAD    305,WHILE,305,WHILE,DOCOL               ; ***** WHILE
        .WORD   IF,TWOP,SEMIS
;
```
