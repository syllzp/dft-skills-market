%chk=ethylene.chk
%mem=4GB
%nprocshared=8
# B3LYP/6-31G(d) Opt=Tight scf=tight int=ultrafine empiricaldispersion=gd3bj

Ethylene (C2H4) geometry optimization at B3LYP/6-31G(d) level

0 1
C        0.000000    0.000000    0.668000
C        0.000000    0.000000   -0.668000
H        0.000000    0.924000    1.237000
H        0.000000   -0.924000    1.237000
H        0.000000    0.924000   -1.237000
H        0.000000   -0.924000   -1.237000

