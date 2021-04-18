
#   excerps from internet

#   https://www.forth.com/starting-forth/5-fixed-point-arithmetic/

#   http://wilsonminesco.com/16bitMathTables/RationalApprox.html

#    All errors less than 10^-7

.word 355, 113       ; π = 3.141 ... 355 / 113       8.5 x 10-8

.word 28667, 10546   ; e = 2.718 ... 28667 / 10546   5.5 x 10-9

.word 19601, 13860   ; √2 = 1.414 ... 19601 / 13860   1.5 x 10-9

.word 18817, 10864   ; √3 = 1.732 ... 18817 / 10864   1.1 x 10-9

.word 22936, 7253    ; √10 = 3.162 ... 22936 / 7253    5.7 x 10-9

.word 26797, 25293   ; 12√2  = 1.059463 ... 26797/25293     -1.7E-9

.word 7050, 10171    ; ln(2)  = 0.6931472 ... 7050/10171     +3.8E-9

.word 12381, 5377    ; ln(10) = 2.302585 ... 12381/5377      -3.6E-9

.word 4004, 13301    ; log(2) = .301029995 ... 4004/13301     +6.9E-9

.word 5377, 12381    ; log(e) = 1.0/ln(10)

.word 10171, 7050    ; lp(e) = 1.0/ln(2)

.word 13301, 4004    ; lp(10) = 1.0/log(2)

.word 127, 50        ; CMIN    cm/in           127/50

.word 50, 127        ; INCM    in/cm           50/127

.word 1250, 381      ; MBYFT   m/ft            1250/381

.word 381, 1250      ; FTBYM   ft/m            381/1250

.word 18, 5          ; MSBYKS  m/s to km/h     18/5

.word 37087, 3792    ; GRAV    gm/s2           37087/3792

.word 28657, 17711   ; PHI     goldem          28657/17711

.word 100, 13704     ; FINER   alpha           100/13704

.word 24559, 8192    ; EMC2    c uni.          24559/8192

.word 1228, 263      ; feigenbaum constant

