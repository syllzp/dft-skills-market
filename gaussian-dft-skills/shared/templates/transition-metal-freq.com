%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> Freq scf=(xqc,tight) int=ultrafine empiricaldispersion=gd3bj

<MOLECULE_NAME> harmonic frequency analysis -- transition metal

<CHARGE> <MULTIPLICITY>
<COORDINATES>

