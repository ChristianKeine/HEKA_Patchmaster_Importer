classdef HEKA_Importer < handle
    %% TODO: ADD DESCRIPTION
    
    properties (Access = public)

        trees = []; % contains tree structure from Patchmaster files: dataTree, stimTree (stimulus parameters), and solTree (solutions)
        opt
        RecTable % contains recordings in table with various parameters, e.g. Rs, Cm, nSweeps ect. 
        solutions = []
        
    end
    
    
    properties (Access = private)
        % PLACEHOLDER
        
    end
    
    %%
    methods (Access = public)
        function obj = HEKA_Importer(filepath,varargin) %CONSTRUCTOR
            
            P = inputParser;
            P.addRequired('filepath',@ischar)
            P.parse(filepath,varargin{:});
            obj.opt = P.Results;        

            obj.HI_loadHEKAFile;

        end
    end
    
  methods (Static, Hidden=false)

            function obj = GUI() % OPEN GUI TO SELECT RECORDING
                
             [file,path] = uigetfile({'*.dat','HEKA PATCHMASTER FILE'},'Select HEKA Patchmaster file to import',...
                 'MultiSelect','off');
              
             obj = HEKA_Importer(fullfile(path,file));
             
            end
  end


    methods (Access = private)
        

        HI_loadHEKAFile(obj,varargin);

        [tree, data,stimTree,solTree] = HI_ImportHEKAtoMat(obj)
        ephysData = HI_SplitSeries(obj,tree, dCollapse, ephysData, saveName,stimTree);
        HI_extractHEKADataTree(obj,tree);
        HI_extractHEKAStimTree(obj,t,stimTree,ephysData);
        HI_extractHEKASolutionTree(obj,solTree);

    end
    
        %% Hide some of the handle class member functions for ease of use.
    methods (Hidden=true)
        function notify(~)
        end
        function addlistener(~)
        end
        function findobj(~)
        end
        function findprop(~)
        end
        function listener(~)
        end
        function delete(~)
        end
    
    end
end


