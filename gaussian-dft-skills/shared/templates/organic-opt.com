%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> Opt=Tight scf=tight int=ultrafine empiricaldispersion=gd3bj

<MOLECULE_NAME> geometry optimization

<CHARGE> <MULTIPLICITY>
<COORDINATES>

