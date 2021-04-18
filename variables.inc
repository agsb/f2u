
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
.word _BASE
.word EXIT

TWIG 3, "TIB"
TIB:
.word DOLIT
.word _TIB
.word EXIT

TWIG 3, ">IN"
TIN:
.word DOLIT
.word _TIN
.word EXIT

TWIG 3, "CUR"
CUR:
.word DOLIT
.word _CUR
.word EXIT

TWIG 3, "CSP"
CSP:
.word DOLIT
.word _CSP
.word EXIT

TWIG 7, "CONTEXT"
CONTEXT:
.word DOLIT
.word _CONTEXT
.word EXIT

TWIG 7, "CURRENT"
CURRENT:
.word DOLIT
.word _CURRENT
.word EXIT

TWIG 7, "HANDLER"
HANDLER:
.word DOLIT
.word _HANDLER
.word EXIT

TWIG 3, "HLD"
HLD:
.word DOLIT
.word _HLD
.word EXIT

TWIG 4, "SPAN"
SPAN:
.word DOLIT
.word _SPAN
.word EXIT

TWIG 3, "SP0"
SPZ:
.word DOLIT
.word _SP0
.word EXIT

TWIG 3, "RP0"
RPZ:
.word DOLIT
.word _RP0
.word EXIT

TWIG 2, "UP"
UP:
.word DOLIT
.word _UP
.word EXIT

TWIG 2, "CP"
CP:
.word DOLIT
.word _CP
.word EXIT

TWIG 5, "STATE"
STATE:
.word DOLIT
.word _STATE
.word EXIT

TWIG 5, "TIMER"
TIMER:
.word DOLIT
.word _TIMER
.word EXIT

TWIG 4, "LAST"
LAST:
.word DOLIT
.word _LAST
.word EXIT

.section .data
.global variables
#.org    0x0060
variables:

_TIMER: .word 1      ;     16 bit counter miliseconds, linked to timer0 interrupt
_RANDW: .word 1      ;     16 bit seed for randow recursive

_HLD: .word 1        ;    pointer to buffer for number convertions
_SPAN: .word 1       ;    number of characters in TIB
_TIN: .word 1        ;     >IN     next character to be interpreted in TIB
_TIH: .word 1        ;    #TIB     number of characters in TIB
_TIB: .word 1        ;     'TIB    start terminal input buffer

_BASE: .word 1       ;     base for show numbers
_CONTEXT: .word 1    ;    pointer to name field of last word in dictionary
_CURRENT: .word 1    ;    pointer to name field of last word in vocaburary
_CP: .word 1         ;    pointer to top free vocabulary
_UP: .word 1         ;     pointer to free user sram
_LAST: .word 1       ;    pointer to name field of last word
_STATE: .word 1      ;    state of $interpreter or $compiler

_SP0: .word 1        ;     parameter stack
_RP0: .word 1        ;    return stack

_TTEVAL: .word 1     ;    reference to eval 
_TTABORT: .word 1    ;    reference to abort
_TTKEYQM: .word 1    ;    reference to key?
_TTEMITQM: .word 1   ;    reference to emit?

_CUR: .word 1        ;     current postion in TIB 
_CSP: .word 1        ;

_HANDLER: .word 1    ;    currenter handler for ?

