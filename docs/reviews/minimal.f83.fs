

@ http://computer-programming-forum.com/22-forth/4d6c1fe89c341c7f.htm

To answer you question; you should ask yourself what you wish to run
and what are the typical high frequency low level operations. Also
you should try to place the most frequently accessed data in registers
and as close to the processor as possible. For a threaded Forth
interpreter using registers for top of stack, the intruction pointer,
the stack pointers, and index registers for I and I' is sufficient.

If you take the Forth-83 glossary you only have to implement
about 35-50 of them on the machine code level and the rest on forth
level to get nice and fast forth interpreter. The selection of virtual
machine registers and the threading method (next) is very important,
also to leave the right "hooks" for multi-tasking.

On a 68K-processor I like to the following direct threaded next to
implement a 16-bit forth:

SP      EQ      A7              ; parameter stack pointer
RP      EQ      A6              ; return stack pointer
IP      EQ      A5              ; instruction (thread) pointer
KP      EQ      A4              ; kernel segment pointer for relocation
TOS     EQ      D7              ; top of parameter stack register
I       EQ      D6              ; current index
I'      EQ      D5              ; last index

MACRO NEXT
        MOVE.W  (IP)+, D0       ; Fetch next thread
        JMP     (D0, KP)        ; And branch to the code field
END.MACRO

DOVARIABLE:
        MOVE.W  (SP), D0        ; Swap the variable address on stack
        MOVE.W  TOS, (SP)       ; with the stack register
        MOVE.W  DO, TOS
        NEXT    

DOCONSTANT:
        MOVE.W  (SP), D0        ; Swap the constant address on stack
        MOVE.W  TOS, (SP)       ; with the stack register
        MOVE.W  (DO, KP), TOS   ; Relocate and fetch value
        NEXT    

DOCOLON:
        MOVE.W  IP, -(RP)               ; Push IP onto the return stack
        MOVE.W  (SP)+, IP               ; Pop the new IP
        NEXT                            ; And go to the next thread

Mikael Patel
All primitives contain code starting at the code field address. A
colon definition has the following code field:

COLONDEFINITION:
        JSR     DOCOLON(KP)

All interpreted words have symmetrical code fields. With top of
stack in a register the primitive arithmetic operation become
easy. Here's an example of the definition of "+".

DOADD:
        ADD.W   (SP)+, TOS
        NEXT

Happy Hunting.....

Mikael R.K. Patel
Researcher and Lecturer
Computer Aided Design Laboratory (CADLAB)
Department of Computer and Information Science
Linkoping University, S-581 83  LINKOPING, SWEDEN

Phone: +46 13281821
Telex: 8155076 LIUIDA S                 Telefax: +46 13142231 


CUT HERE: File: minimal.f83 (tile forth) - - - - - - - - - - -

.( Loading Minimal Forth Machine definitions...) cr

vocabulary minimal

minimal definitions

forth

\ Hardware Devices: Registers and Stacks

: -> ( x -- ) ' >body [compile] literal compile ! ; immediate compilation
: stack ( n -- ) create here swap 2+ cells allot here over cell + ! here swap ! ;



\ Forth Machine Registers
register ir                             ( Instruction register)
register ip                             ( Instruction pointer)
16 stack rp                             ( Return address stack)
register tos                            ( Top of stack register)
16 stack sp                             ( Parameter stack)

\ Dump machine state
: .registers ( -- )
  ." ir: " ir .name space
  ." ip: " ip cell - .
  ." rp: " rp .stack
  ." tos: " tos .
  ." sp: " sp .stack cr ;

\ Forth Machine Instructions
: instruction ( n -- ) create ;
: decode ( -- ) minimal [compile] ['] forth ; immediate compilation

instruction 1+
instruction 0=
instruction NAND
instruction >R
instruction R>
instruction !

instruction EXIT
instruction HALT

: CALL ( -- ) ip rp push ir >body -> ip ;

\ The Minimal Forth Machine

: processor ( -- )
  begin
    fetch-instruction
    .registers
    case
      decode 1+   of tos 1+ -> tos               endof
      decode 0=   of tos 0= -> tos               endof
      decode NAND of sp pop tos and not -> tos   endof
      decode >R   of tos rp push sp pop -> tos   endof
      decode R>   of tos sp push rp pop -> tos   endof
      decode !    of sp pop tos ! sp pop -> tos  endof

      decode EXIT of rp pop -> ip                endof
      decode HALT of true abort" HALT"           endof
      CALL
    endcase
  again ;

: run ( addr -- ) -> ip 0 -> tos ." RUN" cr processor ;

\ A simple compiler for the Minimal Forth Machine

minimal

: CREATE ( -- ) create ;
: COMPILE ( -- ) compile compile ; immediate

: DEFINE ( -- ) CREATE ] ;
: END ( -- ) COMPILE EXIT [compile] [ ; immediate
: BLOCK ( n -- ) cells allot ;
: DATA ( -- ) , ;

\ Variable management

DEFINE [VARIABLE] ( -- addr) R> END
: VARIABLE ( -- addr) CREATE COMPILE [VARIABLE] 1 BLOCK ;

\ Constant management


: CONSTANT ( n -- ) CREATE COMPILE [CONSTANT] DATA ;

\ Basic stack manipulation functions

VARIABLE TEMP

DEFINE DROP ( x -- ) TEMP ! END


DEFINE ROT ( x y z -- y z x) >R SWAP R> SWAP END
DEFINE OVER ( x y -- x y x) >R DUP R> SWAP END

\ Logical function

DEFINE BOOLEAN ( x -- flag) 0= 0= END
DEFINE NOT ( x y -- z) DUP NAND END
DEFINE AND ( x y -- z) NAND NOT END
DEFINE OR ( x y -- z) NOT SWAP NOT NAND END
DEFINE XOR ( x y -- y) OVER OVER NOT NAND >R SWAP NOT NAND R> NAND END

\ Primitive arithmetric functions

DEFINE 1- ( x -- y) NOT 1+ NOT END
DEFINE 2+ ( x -- y) 1+ 1+ END
DEFINE 2- ( x -- y) NOT 2+ NOT END

\ Cell sizes and functions

4 CONSTANT CELL
DEFINE CELL+ ( x -- y) 1+ 1+ 1+ 1+ END

\ Branch instructions



\ Compiler functions

: >MARK ( -- addr) here 0 , ;
: >RESOLVE ( addr -- ) here swap (forth) ! ;
: <MARK ( -- addr) here ;
: <RESOLVE ( -- addr) , ;

: IF ( flag -- ) COMPILE (?BRANCH) >MARK ; immediate
: ELSE ( -- ) COMPILE (BRANCH) >MARK swap >RESOLVE ; immediate
: THEN ( -- ) >RESOLVE ; immediate
: BEGIN ( -- ) <MARK ; immediate
: WHILE ( flag -- ) COMPILE (?BRANCH) >MARK ; immediate
: REPEAT ( -- ) COMPILE (BRANCH) swap <RESOLVE >RESOLVE ; immediate
: UNTIL ( flag -- ) COMPILE (?BRANCH) <RESOLVE ; immediate

\ Simple arithmetrical functions

DEFINE U+ ( x y -- z) BEGIN DUP WHILE 1- SWAP 1+ SWAP REPEAT DROP END
DEFINE NEGATE ( x -- y) NOT 1+ END
DEFINE U- ( x y -- ) BEGIN DUP WHILE 1+ SWAP 1- SWAP REPEAT DROP END

\ Literal numbers in code


: LITERAL ( x -- ) COMPILE (LITERAL) , ; immediate

\ Some test code just to show that it works

DEFINE ARITH-TEST ( -- )
  [ 2 ] LITERAL [ 4 ] LITERAL U+ [ 2 ] LITERAL NEGATE U- HALT
END

\ ARITH-TEST run

DEFINE FIB ( n -- m)
   DUP 1- 0= OVER 0= OR NOT
   IF DUP 1- FIB SWAP 1- 1- FIB U+ THEN
END

DEFINE FIB-TEST
 [ 5 ] LITERAL FIB HALT
END

TEST run 

Please excuse the error that worked its way into the definition of
DOCOLON in the direct threaded forth interpreter for M68K I suggested.

It SHOULD be:

DOCOLON:
        MOVE.W  IP, -(RP)               ; Push IP onto the return stack
        MOVE.W  (SP)+, IP               ; Pop the new IP
        NEXT                            ; And go to the next thread

Mikael Patel

