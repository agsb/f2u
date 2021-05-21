;
;	those are to stay at NRWW flash memory of atmega8
;
.org FLASH_NRWW
.align 2
;
; spm instruction uses:
; r31:r30 address in bytes, r1:r0 data, 
; uses register tmp_low as command and scratch
;
do_spm:
     sts SPMCR, tmp_low
     spm

spm_wait:
;   wait spm done
    lds tmp_low, SPMCR
    sbrc tmp_low, SPMEN
    rjmp spm_wait	

; if erase or write, force enable RWW section 

	andi tmp_low, (1<<PGERS) | (1<<PGWRT)
	breq 10f

; enable rww 
  	ldi tmp_low, (1<<RWWSRE) | (1<<SPMEN)
	sts SPMCR, tmp_low
	spm 

10:
	ret
