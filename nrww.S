;
;	those are to stay at NRWW flash memory of atmega8
;
.org FLASH_NRWW
.align 2
;
; spm instruction uses:
; r31:r30 address in bytes, r1:r0 data, 
; uses register _work_ as command and scratch
;
do_spm:
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
	ret

.equ free_nrww, .

