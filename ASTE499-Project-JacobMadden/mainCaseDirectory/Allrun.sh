#!/bin/bash

# high-level function used to coordinate the CFD-DEM simulation
# first checks for the CFD mesh, then decomposes the domain, 
# initializes the DEM particles if needed, then runs the appropriate parallel CFD-DEM run

# Source CFD run functions
source $WM_PROJECT_DIR/bin/tools/RunFunctions

#- define variables
casePath="$(dirname "$(readlink -f ${BASH_SOURCE[0]})")"

# check if mesh was built
cd $casePath/CFD
if [ -f "$casePath/CFD/constant/polyMesh/points" ]; then
    echo "Mesh was built before - using old mesh"
else
    echo "Mesh needs to be built"
    ./Meshrun
fi

# decompose domain again for CFD solver
runApplication decomposePar -force -copyZero #-copyZero 

if [ -f "$casePath/DEM/post/restart/liggghts.restart" ];  then
    echo "LIGGGHTS init was run before - using existing restart file"
else
    #- run DEM in new terminal to initialize particles  
    $casePath/parDEMrun.sh
fi

# clean out DEM/post folder
mv $casePath/DEM/post/restart $casePath/DEM/
rm -rf $casePath/DEM/post/* 
mv $casePath/DEM/restart $casePath/DEM/post

# keep old couplingProperties
cp $casePath/CFD/constant/couplingProperties $casePath/CFD/constant/couplingProperties_backup
cp $casePath/CFD/0/p $casePath/CFD/0/p_backup

#- run parallel CFD-DEM in new terminal
#gnome-terminal --title='cfdemSolverPiso ErgunTestMPI CFD'  -e "bash $casePath/parCFDDEMrun.sh" 
. $casePath/parCFDDEMrun.sh

# restore old couplingProperties
mv $casePath/CFD/constant/couplingProperties_backup $casePath/CFD/constant/couplingProperties
mv $casePath/CFD/0/p_backup $casePath/CFD/0/p 
