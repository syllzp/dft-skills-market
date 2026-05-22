%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> Opt=Tight scf=(tight,nosymm) int=(ultrafine,acc2e=12) empiricaldispersion=gd3bj <SOLVATION>

<MOLECULE_NAME> geometry optimization -- charged species

<CHARGE> <MULTIPLICITY>
<COORDINATES>

