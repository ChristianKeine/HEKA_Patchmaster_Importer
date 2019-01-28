function HI_loadHEKAFile(obj)

% CHECK IF FILE EXISTS
if ~exist(obj.opt.filepath,'file')
    warning('File not found'); return
end

   
    
    % CREATE PRELIM STRUCTURE FOR EPHYS DATA
    ephysData = struct();
    
    %% CALL IMPORT FUNCTION
    [tree, data,stimTree, solTree] = obj.HI_ImportHEKAtoMat;
    
    for i = length(data):-1:1
        dCollapse(1:length(data{i}))= data{i};
    end
    
    
    [~,saveName] = fileparts(obj.opt.filepath);
    
    % Split the data into series by recording name, etc. and assign into
    % the final data structure
    
    % TODO: DOUBLE CHECK FOR SAVE OPTIONS
    ephysData = obj.HI_SplitSeries(tree, dCollapse, ephysData, saveName,stimTree);
    
    
    obj.HI_extractHEKADataTree(tree);
    obj.HI_extractHEKAStimTree(stimTree);
    obj.HI_extractHEKASolutionTree(solTree);


    f = fields(ephysData);

    dataRaw = cell(size(f));
    SR = cell(size(f));
for iExp = 1:numel(f)
    dataRaw{iExp,:} = reshape(ephysData.(f{iExp}).data(1,:),numel(ephysData.(f{iExp}).data(1,:)),1);
    SR{iExp,:} =  reshape([ephysData.(f{iExp}).samplingFreq{:}], numel([ephysData.(f{iExp}).samplingFreq{:}]),1); 
end

    obj.RecTable.dataRaw = vertcat(dataRaw{:});
    obj.RecTable.SR = vertcat(SR{:});
    
    %% ADD MINIMUM RANDOM NUMBER TO AVOID DISCRETIZATION
    
    addEPS = @(x) x+randn(size(x))*eps;    
    obj.RecTable.dataRaw = cellfun(addEPS,obj.RecTable.dataRaw,'UniformOutput',false);
    

    obj.trees = struct('dataTree',{tree},'stimTree',{stimTree},'solutionTree',{solTree});

    
end
