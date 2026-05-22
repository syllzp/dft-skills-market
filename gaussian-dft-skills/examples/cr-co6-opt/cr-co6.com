%chk=cr-co6.chk
%mem=8GB
%nprocshared=16
# PBE0/def2-TZVP Opt=Tight scf=(xqc,tight) int=ultrafine empiricaldispersion=gd3bj

Cr(CO)6 geometry optimization at PBE0/def2-TZVP level -- singlet transition metal complex

0 1
Cr       0.000000    0.000000    0.000000
C        0.000000    0.000000    1.912000
O        0.000000    0.000000    3.060000
C        0.000000    0.000000   -1.912000
O        0.000000    0.000000   -3.060000
C        0.000000    1.912000    0.000000
O        0.000000    3.060000    0.000000
C        0.000000   -1.912000    0.000000
O        0.000000   -3.060000    0.000000
C        1.912000    0.000000    0.000000
O        3.060000    0.000000    0.000000
C       -1.912000    0.000000    0.000000
O       -3.060000    0.000000    0.000000

