
.section .data
.global variables
.org    0x0060
variables:

_wNULL:	 .word 1	  ; 16 bit NULL must be zero.
_wTIMER: .word 1      ; 16 bit counter miliseconds, linked to timer0 interrupt
_wRANDW: .word 1      ; 16 bit seed for pseudo random recursive
_wHASH:	 .word 1	  ; 16 bit djd hash seed 5381 

_wHLD: .word 1        ; pointer to buffer for number convertions
_wSPN: .word 1        ; number of characters in TIB
_wTIN: .word 1        ; >IN     next character to be interpreted in TIB
_wTIH: .word 1        ; #TIB    number of characters in TIB
_wTIB: .word 1        ; 'TIB    start terminal input buffer

_wSTATE: .word 1      ;    state of $interpreter or $compiler
_wBASE: .word 1       ;    base for show numbers
_wLAST: .word 1       ;    pointer to last word of vocabulary
_wCONTEXT: .word 4    ;    pointer to vocabularies (primitives, devices, forth, applications)
_wCURRENT: .word 1    ;    pointer to current vocaburary
_wCP: .word 1         ;    pointer to top free vocabulary
_wUP: .word 1         ;    pointer to free user sram

_wTTEVAL: .word 1     ;    reference to eval 
_wTTABORT: .word 1    ;    reference to abort
_wTTKEYQM: .word 1    ;    reference to key?
_wTTEMITQM: .word 1   ;    reference to emit?

