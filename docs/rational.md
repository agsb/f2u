
# Rational fractions

From excerps from internet
> https://www.forth.com/starting-forth/5-fixed-point-arithmetic/

> http://wilsonminesco.com/16bitMathTables/RationalApprox.html

PS. All errors less than 10^-7

 | name | dividend | divisor | rational for |
 |:-----|---------:|--------:|:-------------|
 | _rPI:  |    355 | 113      | ; π = 3.141  |
 | _rEULER:  |    28667 | 10546  | ; e = 2.718  |
 | _rSQRTWO:  |    19601 | 13860  | ; √2 = 1.414  |
 | _rSQRTRI:  |    18817 | 10864  | ; √3 = 1.732  |
 | _rSQRTEN:  |    22936 | 7253   | ; √10 = 3.162  |
 | _rMUSIC:  |    26797 | 25293  | ; 12√2  = 1.059 |
 | _rLNTWO:  |    7050 | 10171   | ; ln(2)  = 0.6931  |
 | _rLNTEN:  |    12381 | 5377   | ; ln(10) = 2.302  |
 | _rLOGTWO:  |    4004 | 13301   | ; log(2) = 0.3010  |
 | _rILNTEN:  |    5377 | 12381   | ; log(e) = 1.0/ln(10) |
 | _rILNTWO:  |    10171 | 7050   | ; lp(e) = 1.0/ln(2) |
 | _rILOGTWO:  |    13301 | 4004   | ; lp(10) = 1.0/log(2) |
 | _rCMIN:  |    127 | 50       | ; convert cm to in  |
 | _rINCM:  |    50 | 127       | ; convert in to cm  |
 | _rMTFT:  |    1250 | 381     | ; convert m to ft   |
 | _rFTMT:  |    381 | 1250     | ; convert ft to m   |
 | _rMSKH:  |    18 | 5         | ; convert m/s to km/h   |
 | _rGRAV:  |    37087 | 3792   | ; GRAV gm/s2    |
 | _rPHI:  |    28657 | 17711  | ; PHI goldem ratio   |
 | _rFINE:  |    100 | 13704    | ; FINER   alpha  |
 | _rEMC:  |    24559 | 8192   | ; EMC2    c uni.    |
 | _rFRAC:  |    1228 | 263     | ; feigenbaum constant |
 | _rCORDIC: | 9260 | 15249 | ; cordic constant | 
