
.section .data
.global variables
.org    0x0060
variables:

_wTIMER: .word 1      ;     16 bit counter miliseconds, linked to timer0 interrupt
_wRANDW: .word 1      ;     16 bit seed for randow recursive

_wHLD: .word 1        ;    pointer to buffer for number convertions
_wSPAN: .word 1       ;    number of characters in TIB
_wTIN: .word 1        ;     >IN     next character to be interpreted in TIB
_wTIH: .word 1        ;    #TIB     number of characters in TIB
_wTIB: .word 1        ;     'TIB    start terminal input buffer

_wBASE: .word 1       ;    base for show numbers
_wCONTEXT: .word 4    ;    pointer to vocabularies (primitives, devices, forth, applications)
_wCURRENT: .word 1    ;    pointer to current vocaburary
_wCP: .word 1         ;    pointer to top free vocabulary
_wUP: .word 1         ;    pointer to free user sram
_wLAST: .word 1       ;    pointer to name field of last word
_wSTATE: .word 1      ;    state of $interpreter or $compiler

_wSP0: .word 1        ;    parameter stack
_wRP0: .word 1        ;    return stack

_wTTEVAL: .word 1     ;    reference to eval 
_wTTABORT: .word 1    ;    reference to abort
_wTTKEYQM: .word 1    ;    reference to key?
_wTTEMITQM: .word 1   ;    reference to emit?

_wCUR: .word 1        ;     current postion in TIB 
_wCSP: .word 1        ;

_wHANDLER: .word 1    ;    currenter handler for ?

