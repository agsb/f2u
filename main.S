; atmega8 avr

;---------------------------------------------------------------------

#include "macros.S"

.section data
.org 0x0060
sram:

NULL:	.word 0
TIN:	.word 0
HERE:	.word 0
STATE:	.word 0
LAST:	.word 0
BASE:	.word 0
RSP:	.space RSP_SIZE, 0
PSP:	.space PSP_SIZE, 0 
PAD:	.space PAD_SIZE, 0
TIB: 	.space TIB_SIZE, 0

.section data 
.org 0x0100
freesram:

.section text
.org 0x0000
#include "boot.S"

.section text
.org 0x0100
#include "head.S"


