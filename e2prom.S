
/*
 *  DISCLAIMER"
 *
 *  Copyright © 2020, Alvaro Gomes Sobral Barcellos,
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions"
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *
 */

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





