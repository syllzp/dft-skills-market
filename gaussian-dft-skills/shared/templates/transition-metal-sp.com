%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> scf=(xqc,tight) int=ultrafine empiricaldispersion=gd3bj pop=mulliken

<MOLECULE_NAME> single-point energy -- transition metal

<CHARGE> <MULTIPLICITY>
<COORDINATES>

