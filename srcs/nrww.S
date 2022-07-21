
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
;   this is from a patch request to optiboot/optiboot, called bb_spm
;   must stay in NRWW flash pages
;   will go in interrupt table at 0x004 "external interrupt 1"
;   
;.org FLASH_NRWW
;.align 2
;
; spm instruction uses:
;
; must be defined by caller:
; r31:r30 page/word address, r1:r0 data, 
;
; uses register r24 as command and scratch
; uses register r25 as keeper of SREG
;

#ifdef BB_SPM

    _swork_ = r24
    _ssreg_ = r25

;
; bare bones 
; 
bb_spm:
    in _ssreg_, __SREG__
    cli
    sts SPMCR, _swork_
    spm
;   wait spm done
10: lds _swork_, SPMCR
    sbrc _swork_, SPMEN
    rjmp 10b
;   return
    out __SREG__, _ssreg_
    ret

#elseif

does_spm:
    call 0x004

#endif

.equ nrww_end, .

