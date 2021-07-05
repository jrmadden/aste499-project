#!/bin/bash

# function used for parallel run of the CFD-DEM simulation
# first runs the main simulation and then checks on post-processing
# simulation IO parameters can be modified below

#- source CFDEM env vars
. ~/.bashrc

#- define variables
casePath="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"

#- include functions
source $CFDEM_SRC_DIR/lagrangian/cfdemParticle/etc/functions.sh     #DEM
source $WM_PROJECT_DIR/bin/tools/RunFunctions                       #CFD

#--------------------------------------------------------------------------------#
#- define variables
casePath="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"
logpath=$casePath
headerText="run_parallel_cfdemSolverPiso_ErgunTestMPI_CFDDEM"
logfileName="log_$headerText"
solverName="cfdemSolverPiso"
nrProcs="8"
machineFileName="none"   # yourMachinefileName | none
debugMode="off"          # on | off| strict | profile
reconstructCase="false"
decomposeCase="fale"
testHarnessPath="$CFDEM_TEST_HARNESS_PATH"
runOctave="false"
postproc="true"
#--------------------------------------------------------------------------------#

#- call function to run a parallel CFD-DEM case
parCFDDEMrun $logpath $logfileName $casePath $headerText $solverName $nrProcs $machineFileName $debugMode $reconstructCase $decomposeCase


if [ $runOctave == "true" ]
    then
        #------------------------------#
        #  octave

        #- change path
        cd octave

        #- rmove old graph
        rm cfdemSolverPiso_ErgunTestMPI.png

        #- run octave
        octave --no-gui totalPressureDrop.m

        #- show plot 
        eog cfdemSolverPiso_ErgunTestMPI.png

        #- copy log file to test harness
        cp ../../$logfileName $testHarnessPath
        cp cfdemSolverPiso_ErgunTestMPI.png $testHarnessPath
fi

if [ $postproc == "true" ]
  then

    # keep terminal open (if started in new terminal)
    echo "Simulation finished...Press enter to post-process DEM and CFD data"
    read

    # run post-processing script
    $casePath/Postproc

    echo "CFD file located at .../CFD/CFD.foam (use 'Decomposed Case' in Paraview"
    echo "DEM file located at .../DEM/post/liggghts_run.pvd"

    # keep terminal open (if started in new terminal)
    echo "Use 'Allclean' script to clean case"
    #echo "...Press enter to clean up case"
    #echo "Press Ctr+C to keep data"
    #read
    paraview
fi

# clean up case
#keepDEMrestart="true"
#keepCFDmesh="true"
#cleanCFDEMcase $casePath/CFD $keepDEMrestart $keepCFDmesh > log.cleanCFDEMcase
