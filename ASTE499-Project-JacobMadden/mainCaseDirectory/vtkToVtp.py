#! /usr/bin/python

# import paraview API
from paraview.simple import *
import os
import sys


def listVtkFiles(directory, extension):
    return (f for f in os.listdir(directory) if f.endswith('.' + extension))

def main(path):

    print("Working directory: " + path)

    # create .pvd file with timestamps
    pvdFileName = "liggghts_run.pvd"
    pvdFile = open(pvdFileName, "w+")
    pvdFile.write("<VTKFile type='Collection' version='1.0' byte_order='LittleEndian' header_type='UInt64'>\n<Collection>")

    # Get the list of all files in directory tree at given path
    files = listVtkFiles(path, "vtk")

    # timetep data
    initSteps = 1.1e4         # number of steps taken for DEM init
    dt = 1e-5            # DEM timestep

    # loop through files and convert all to .vtp
    for f in files:

        # set up new file name
        strLen = len(f)
        nameStep = int(f[strLen - 9:strLen - 4])
        trueStep = nameStep - initSteps

        # check if data has reached CFD simulation start time yet
        if (trueStep < 0):
            continue
        newFileName = "post_" + f[0:strLen - 3] + "vtp"
        # print(newFileName)

        # prepare reader
        r = LegacyVTKReader(FileNames=[f])

        # set up writer
        w = XMLPolyDataWriter()
        w.FileName = newFileName
        w.UpdatePipeline()

        # write to .pvd file
        timestep = float(dt) * trueStep
        pvdFile.write("<DataSet     timestep='" + str(timestep) + "'\nfile='" + newFileName + "'/>\n")

    # close out .pvd file
    pvdFile.write("</Collection>\n</VTKFile>")

    print("Finished writing " + pvdFileName)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = sys.argv[1]
    else:
        path = os.getcwd()
    main(path)
