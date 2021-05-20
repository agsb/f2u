.set _pc,  pc

;.org NRWW_START_ADDR

; 0xC00
.org 0x1800

do_spm:
     out SPMCR, tmp_low
     spm

spm_wait:
;   wait till spm done
    in      tmp_low, 0x37    ; 55
    sbrc    tmp_low, 0
    rjmp    spm_wait	

; if erase or write 

	andi tmp_low, 0x06
	brne 10f

; enable rww 
  	ldi tmp_low, (1<<RWWSRE) | (1<<SPMEM)
	out SPMCR, tmp_low
	spm 

10:
	ret

.org _pc
