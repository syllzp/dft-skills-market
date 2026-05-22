%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> scf=tight int=(ultrafine,acc2e=12) empiricaldispersion=gd3bj pop=mulliken nosymm

<MOLECULE_NAME> single-point energy -- charged species

<CHARGE> <MULTIPLICITY>
<COORDINATES>

