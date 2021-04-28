
;----------------------------------------------------------------------
;
;    SRAM for user start at 0x060, 
;    forth reserves 0x060 to 0x0BF, about 48 words
;    user  variables starts at 0x0C0
;
;    Better Save Space.' Since the BSS segment only holds variables that don't have any value yet,
;
;----------------------------------------------------------------------
;
;    puts literal (word) into parameter stack
;

;----------------------------------------------------------------------
;
;    ok  push address of "" into parameter stack
;
;    .s/.equ \+\(.\+\) ,.\+/TWIG 0, "\1"\r;ISVARIABLE \1\r/

;
;----------------------------------------------------------------------

;----------------------------------------------------------------------
;
;    creates forth variables, pushes the address
;
TWIG 4, "BASE"
BASE:
.word DOLIT
.word _wBASE
.word _LAST

TWIG 3, "TIB"
TIB:
.word DOLIT
.word _wTIB
.word _LAST

TWIG 3, ">IN"
TIN:
.word DOLIT
.word _wTIN
.word _LAST

TWIG 7, "CONTEXT"
CONTEXT:
.word DOLIT
.word _wCONTEXT
.word _LAST

TWIG 7, "CURRENT"
CURRENT:
.word DOLIT
.word _wCURRENT
.word _LAST

TWIG 3, "HLD"
HLD:
.word DOLIT
.word _wHLD
.word _LAST

TWIG 2, "UP"
UP:
.word DOLIT
.word _wUP
.word _LAST

TWIG 2, "CP"
CP:
.word DOLIT
.word _wCP
.word _LAST

TWIG 5, "STATE"
STATE:
.word DOLIT
.word _wSTATE
.word _LAST

TWIG 4, "LAST"
TWIG 4, "LAST"
LAST:
.word DOLIT
.word _wLAST
.word _LAST

