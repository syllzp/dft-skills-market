%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> TD=(NStates=<NROOTS>,Root=1) scf=tight int=ultrafine empiricaldispersion=gd3bj

<MOLECULE_NAME> TDDFT excited-state calculation

<CHARGE> <MULTIPLICITY>
<COORDINATES>

