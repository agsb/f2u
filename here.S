;----------------------------------------------------------------------
; ok ( -- w)
;
HEADER "HERE", "here_"
    NOOP
    ldi zpm_low, lo8(HERE)
    ldi zpm_high, hi8(HERE)
    srload wrk_low
    srload wrk_high
    WOOP

