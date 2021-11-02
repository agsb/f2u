
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

;
;    those are to stay at NRWW flash memory of atmega8
;
.org FLASH_NRWW
.align 2
;
; spm instruction uses:
; r31:r30 address in bytes, r1:r0 data, 
; uses register r2 as command and scratch
; uses register r4 as keeper of SREG
;
#ifndef _WORK_
	_work_ = r2
	_sreg_ = r4
#endif

do_spm:
	in _sreg_, __SREG__
	cli
    sts SPMCR, _work_
    spm

10:
;   wait spm done
    lds _work_, SPMCR
    sbrc _work_, SPMEN
    rjmp 10b

; if erase or write, force enable RWW section 

    andi _work_, (1<<PGERS) | (1<<PGWRT)
    breq 10f

; enable rww 
    ldi _work_, (1<<RWWSRE) | (1<<SPMEN)
    sts SPMCR, _work_
    spm 
10:
	out __SREG__, _sreg_
	sei
    ret

.equ free_nrww, .

