%chk=<NAME>.chk
%mem=<MEMORY_MB>MB
%nprocshared=<N_CORES>
# <FUNCTIONAL>/<BASIS> Freq scf=tight int=ultrafine empiricaldispersion=gd3bj

<MOLECULE_NAME> harmonic frequency analysis -- pre-optimization

<CHARGE> <MULTIPLICITY>
<COORDINATES>

