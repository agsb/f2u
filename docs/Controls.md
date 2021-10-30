Controls.md


# eforth

```
\ 5.2 primitive compiler words
: ' TOKEN NAME? IF EXIT THEN THROW ;
: , HERE DUP CELL+ CP ! ! ;
: ALLOT CP +! ;
: [COMPILE] R> DUP @ , CELL+ R> ;
: COMPILE ' , ; IMMEDIATE
: LITERAL COMPILE DOLIT , ; IMMEDIATE
: $," 34 WORD COUNT ALIGNED CP ! ;
: RECURSE LAST @ NAME> , ; IMMEDIATE

\ 5.3 strutures
\ _IF_THEN
\ _IF_ELSE_THEN
\ _FOR_NEXT
\ _FOR_AFT_THEN_NEXT
\ _BEGIN_AGAIN
\ _BEGIN_UNTIL
\ _BEGIN_WHILE_REPEAT
: <MARK HERE ;
: <RESOLVE , ;
: >MARK HERE 0 , ;
: >RESOLVE <MARK SWAP ! ;
: FOR COMPILE >R <MARK ; IMMEDIATE
: BEGIN <MARK ; IMMEDIATE
: NEXT COMPILE NEXT <RESOLVE ; IMMEDIATE
: UNTIL COMPILE ?BRANCH <RESOLVE ; IMMEDIATE
: AGAIN COMPILE BRANCH <RESOLVE ; IMMEDIATE
: IF COMPILE ?BRANCH >MARK ; IMMEDIATE
: AHEAD COMPILE BRANCH >MARK ; IMMEDIATE
: REPEAT [COMPILE] AGAIN >RESOLVE ; IMMEDIATE
: THEN >RESOLVE ; IMMEDIATE
: AFT DROP [COMPILE] AHEAD [COMPILE] BEGIN SWAP ; IMMEDIATE
: ELSE [COMPILE] AHEAD SWAP [COMPILE] THEN ; IMMEDIATE
: WHEN [COMPILE] IF OVER ; IMMEDIATE
: WHILE [COMPILE] IF SWAP ; IMMEDIATE
: ABORT" COMPILE ABORT" $," ; IMMEDIATE
: $" COMPILE $"| $," ; IMMEDIATE
: ." COMPILE ."| $," ; IMMEDIATE
```
# jonasforth

- HERE is handled as common variable, while in most Forth is defined by : HERE DP @ ;

- immediate must be called inside and first

- ' (tick) and , (comma) does all magic

```
\ IF is an IMMEDIATE word which compiles 0BRANCH followed by a dummy offset, and places
\ the address of the 0BRANCH on the stack.  Later when we see THEN, we pop that address
\ off the stack, calculate the offset, and back-fill the offset.


: IF IMMEDIATE
        ' 0BRANCH ,     \ compile 0BRANCH
        HERE @          \ save location of the offset on the stack
        0 ,             \ compile a dummy offset
;

: THEN IMMEDIATE
        DUP
        HERE @ SWAP -   \ calculate the offset from the address saved on the stack
        SWAP !          \ store the offset in the back-filled location
;

: ELSE IMMEDIATE
        ' BRANCH ,      \ definite branch to just over the false-part
        HERE @          \ save location of the offset on the stack
        0 ,             \ compile a dummy offset
        SWAP            \ now back-fill the original (IF) offset
        DUP             \ same as for THEN word above
        HERE @ SWAP -
        SWAP !
;

\ BEGIN loop-part condition UNTIL
\       -- compiles to: --> loop-part condition 0BRANCH OFFSET
\       where OFFSET points back to the loop-part
\ This is like do { loop-part } while (condition) in the C language
: BEGIN IMMEDIATE
        HERE @          \ save location on the stack
;

: UNTIL IMMEDIATE
        ' 0BRANCH ,     \ compile 0BRANCH
        HERE @ -        \ calculate the offset from the address saved on the stack
        ,               \ compile the offset here
;

\ BEGIN loop-part AGAIN
\       -- compiles to: --> loop-part BRANCH OFFSET
\       where OFFSET points back to the loop-part
\ In other words, an infinite loop which can only be returned from with EXIT
: AGAIN IMMEDIATE
        ' BRANCH ,      \ compile BRANCH
        HERE @ -        \ calculate the offset back
        ,               \ compile the offset here
;

\ BEGIN condition WHILE loop-part REPEAT
\       -- compiles to: --> condition 0BRANCH OFFSET2 loop-part BRANCH OFFSET
\       where OFFSET points back to condition (the beginning) and OFFSET2 points to after the whole piece of code
\ So this is like a while (condition) { loop-part } loop in the C language
: WHILE IMMEDIATE
        ' 0BRANCH ,     \ compile 0BRANCH
        HERE @          \ save location of the offset2 on the stack
        0 ,             \ compile a dummy offset2
;

: REPEAT IMMEDIATE
        ' BRANCH ,      \ compile BRANCH
        SWAP            \ get the original offset (from BEGIN)
        HERE @ - ,      \ and compile it after BRANCH
        DUP
        HERE @ SWAP -   \ calculate the offset2
        SWAP !          \ and back-fill it in the original location
;

\ UNLESS is the same as IF but the test is reversed.
\
\ Note the use of [COMPILE]: Since IF is IMMEDIATE we don't want it to be executed while UNLESS
\ is compiling, but while UNLESS is running (which happens to be when whatever word using UNLESS is
\ being compiled -- whew!).  So we use [COMPILE] to reverse the effect of marking IF as immediate.
\ This trick is generally used when we want to write our own control words without having to
\ implement them all in terms of the primitives 0BRANCH and BRANCH, but instead reusing simpler
\ control words like (in this instance) IF.
: UNLESS IMMEDIATE
        ' NOT ,         \ compile NOT (to reverse the test)
        [COMPILE] IF    \ continue by calling the normal IF
;


