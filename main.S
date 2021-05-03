; atmega8 avr

;---------------------------------------------------------------------

; sram 	internal mapped 0x000 to 0x05F, free fo use 0x060 to 0x45F,  
; flash bios 0x000 to 0x45F, forth 0x460 to 0xCFFF, boot 0xCFFF to 0x1FFF

#include "macros.S"

.section data
.org 0x0060
sram:

NULL:	.word 0
TOIN:	.word 0
HERE:	.word 0
STATE:	.word 0
LAST:	.word 0
BASE:	.word 0
RSP:	.space RSP_SIZE, 0
PSP:	.space PSP_SIZE, 0 
PAD:	.space PAD_SIZE, 0
TIB: 	.space TIB_SIZE, 0
.equ free_sram, .

#include "bios.S"

#include "forth.S"

#include "more.S"

.equ free_flash, .

