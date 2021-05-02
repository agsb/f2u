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
RP0:	.space 40, 0
SP0:	.space 40, 0 
PAD:	.space 80, 0
TIB: 	.space 80, 0

.section data 
.org 0x0100
freesram:

.section text
.org 0x0000
#include "boot.S"

.section text
.org 0x0100
#include "head.S"

