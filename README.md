# HEKA Patchmaster Importer

Class to import HEKA Patchmaster files into Matlab.
The core functionality is based on the HEKA importer from sigTool (10.1016/j.neuron.2015.10.042 and https://github.com/irondukepublishing/sigTOOL) with modifications from Sammy Katta (https://github.com/sammykatta/Matlab-PatchMaster).

This stand-alone importer works independent of sigTool and will additionally extract the stimulus (reconstructed from the pgf) and solutions (when solution base was active during recording). 

The recordings will be sorted into a table together with various parameters such as Rs, Cm, Vhold. 

**How to use:



