%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> Freq scf=tight int=(ultrafine,acc2e=12) empiricaldispersion=gd3bj nosymm

<MOLECULE_NAME> harmonic frequency analysis -- charged species

<CHARGE> <MULTIPLICITY>
<COORDINATES>

