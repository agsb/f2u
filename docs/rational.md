 |
#   excerps from internet |
 |
#   https://www.forth.com/starting-forth/5-fixed-point-arithmetic/ |
 |
#   http://wilsonminesco.com/16bitMathTables/RationalApprox.html |
 |
#    All errors less than 10^-7 |
 |
| _rPI:  | .word  355, 113      | ; π = 3.141  |
| _rEULER:  | .word  28667, 10546  | ; e = 2.718  |
| _rSQRTWO:  | .word  19601, 13860  | ; √2 = 1.414  |
| _rSQRTRI:  | .word  18817, 10864  | ; √3 = 1.732  |
| _RSQRTEN:  | .word  22936, 7253   | ; √10 = 3.162  |
| _RMUSIC:  | .word  26797, 25293  | ; 12√2  = 1.059463  |
| _rLNTWO:  | .word  7050, 10171   | ; ln(2)  = 0.6931472  |
| _rLNTEN:  | .word  12381, 5377   | ; ln(10) = 2.302585  |
| _rLOGTWO:  | .word  4004, 13301   | ; log(2) = .301029995  |
| _rILNTEN:  | .word  5377, 12381   | ; log(e) = 1.0/ln(10) |
| _rILNTWO:  | .word  10171, 7050   | ; lp(e) = 1.0/ln(2) |
| _rILOGTWO:  | .word  13301, 4004   | ; lp(10) = 1.0/log(2) |
| _rCMIN:  | .word  127, 50       | ; CMIN    cm/in  |
| _rINCM:  | .word  50, 127       | ; INCM    in/cm  |
| _rMTFT:  | .word  1250, 381     | ; MBYFT   m/ft   |
| _rFTMT:  | .word  381, 1250     | ; FTBYM   ft/m   |
| _rMSKH:  | .word  18, 5         | ; MSBYKS  m/s to km/h   |
| _rGRAV:  | .word  37087, 3792   | ; GRAV    gm/s2    |
| _rPHI:  | .word  28657, 17711  | ; PHI     goldem   |
| _rFINE:  | .word  100, 13704    | ; FINER   alpha  |
| _rEMC:  | .word  24559, 8192   | ; EMC2    c uni.    |
| _rFRAC:  | .word  1228, 263     | ; feigenbaum constant |
|  |
