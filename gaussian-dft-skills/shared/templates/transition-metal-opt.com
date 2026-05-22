%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> Opt=Tight scf=(xqc,tight) int=ultrafine empiricaldispersion=gd3bj <SOLVATION>

<MOLECULE_NAME> geometry optimization -- transition metal complex

<CHARGE> <MULTIPLICITY>
<COORDINATES>

