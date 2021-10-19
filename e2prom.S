;----------------------------------------------------------------------
;
; ok 
;	save into and load from eeprom
;
HEADER "(here!e)", "hereto"
	.word HERE, AT, e_here, weep, ENDS

HEADER "(here@e)", "hereat"
	.word e_here, reep, HERE, TO, ENDS

HEADER "(last!e)", "lastto"
	.word LAST, AT, e_last, weep, ENDS

HEADER "(last@e)", "lastat"
	.word e_last, reep, LAST, TO, ENDS

HEADER "(seed!e)", "seedto"
	.word SEED, AT, e_seed, weep, ENDS

HEADER "(seed@e)", "seedat"
	.word e_seed, reep, SEED, TO, ENDS

HEADER "(sram!e)", "sramto"
	.word SRAM, AT, e_sram, weep, ENDS

HEADER "(sram@e)", "sramat"
	.word e_sram, reep, SRAM, TO, ENDS

HEADER "(erom!e)", "eromto"
	.word EROM, AT, e_erom, weep, ENDS

HEADER "(erom@e)", "eromat"
	.word e_erom, reep, EROM, TO, ENDS





