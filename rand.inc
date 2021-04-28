;----------------------------------------------------------------------
;
; http://www.avr-asm-tutorial.net/avr_en/apps/random_tn13/random_calc_tn13.html
;
;    seed ~ 0x02A8
;
;	 also good seeds
;
;    B167 4A3C 9879 B61E 7B26 
;    A858 1F88 50D5 419D 5537
;    0224 0527 5EB6 1E6D BCDC
;    92FF C206 0ECD 9361 2823
;    BE0B B303 6462 0E4C 3D24
;
LEAF 3, "_RND_"
RND:
	NOOP
;    load seed
    lds wrk_low, _wRANDW
    lds wrk_high, _wRANDW + 1
;
;    run magics
;
    eor wrk_low, wrk_high
    swap wrk_low
    add wrk_high, wrk_low

;    save seed
    sts _wRANDW, wrk_low
    sts _wRANDW + 1, wrk_high
;
	pspush wrk_low, wrk_high
    POON
    
