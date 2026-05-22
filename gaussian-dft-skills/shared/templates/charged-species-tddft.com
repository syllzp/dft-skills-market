%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> TD=(NStates=<NROOTS>,Root=1) scf=tight int=(ultrafine,acc2e=12) empiricaldispersion=gd3bj nosymm

<MOLECULE_NAME> TDDFT excited-state calculation -- charged species

<CHARGE> <MULTIPLICITY>
<COORDINATES>

