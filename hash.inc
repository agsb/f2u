.equ HASH=5381

movw wrk_low, tos_low


mov 

_HASH:
sub 

; hash = (hash << 5) + str[i]

ld tos_low, X+
ld tos_high, X+

lsf wrk_low
lsc wrk_high

lsf wrk_low
lsc wrk_high

lsf wrk_low
lsc wrk_high

lsf wrk_low
lsc wrk_high

lsf wrk_low
lsc wrk_high

add wrk_low, tos_low
adc wrk_high, tos_high

; next 

rjmp _HASH
