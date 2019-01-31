function HI_extractHEKADataTree(obj,tree)


%1: Root
%2 Group/Experiment
%3: series/Recording number
%4: Sweep
%5: Trace/channel


allExp = find(~cellfun(@isempty,tree(:,2)));
nExperiments = numel(allExp);

Rt = cell(nExperiments,1);

for iExp = 1:nExperiments
   if iExp == nExperiments
       nextExp = size(tree,1)+1;
   else
       nextExp = allExp(iExp+1);
   end
   Rt{iExp} = ImportRecordings(tree,allExp(iExp),nextExp,iExp); 
end

obj.RecTable = [vertcat(Rt{:}),obj.RecTable];



end



function RecTab = ImportRecordings(tree,thisExpID,nextExpID,ExpNum)


% RESORT STRUCTUREES TO ALSO CONTAIN SWEEP AND TRACE/CHANNEL INFORMATION
recIDs = find(~cellfun(@isempty,tree(:,3)));
recIDs = recIDs(recIDs>thisExpID & recIDs<nextExpID);

sweepSt = recIDs+1; sweepEnd = [recIDs(2:end)-1;size(tree,1)];

for iR = 1:numel(recIDs)
    % GET RECORDING INFORMATION
    Recs(iR) = tree{recIDs(iR),3};
    
    %GET ASSOCIATED SWEEPS & TRACES
    Recs(iR).Sweeps = ImportSweeps(tree(sweepSt(iR):sweepEnd(iR),4:5));
    

end


% GET EXPERIMENT NAMES
nRecs = numel(Recs);
ExperimentName = repmat(tree{thisExpID,2}.GrLabel,nRecs,1);
ExperimentNumber = repmat(ExpNum,nRecs,1);
recNum = reshape(1:nRecs,nRecs,1);

%EXTRACT INFORMATION FROM LEVEL 3
Stimulus = reshape({Recs(:).SeLabel},numel(Recs),1);
comment = reshape({Recs(:).SeComment},numel(Recs),1);
nSweeps = reshape([Recs(:).SeNumbersw],numel(Recs),1);


%EXTRACT INFORMATION FROM AMPLIFIER STATE, LEVEL 3
AmpState = [Recs(:).SeAmplifierState];
Rs_uncomp = reshape(1./[AmpState(:).E9GSeries],numel(AmpState),1);
Rs = Rs_uncomp - reshape([AmpState(:).E9RsValue],numel(AmpState),1);
Cm = reshape([AmpState(:).E9CSlow],numel(AmpState),1);
RsFractionComp = reshape([AmpState(:).E9RsFraction],numel(AmpState),1);
Vhold = reshape([AmpState(:).E9VHold],numel(AmpState),1);

% ASSUME TEMPERATURE AND SOLUTIONS ARE IDENTICAL BETWEEN SWEEPS AND LOAD
% FIRST SWEEP ONLY OF EACH RECORDING

Temperature = NaN(nRecs,1);
TimeUnit = cell(nRecs,1);
ChUnit = cell(nRecs,1);
RecModeID = cell(nRecs,1);
ExternalSolutionID = cell(nRecs,1);
InternalSolutionID = cell(nRecs,1);
RecordingMode = cell(nRecs,1);

RecModeNames = {'inside-out V-clamp','on-cell V-clamp','outside-out V-clamp','Whole-cell V-clamp','C-clamp'};

for iR=1:nRecs
Temperature(iR,:) = Recs(iR).Sweeps(1).SwTemperature;

% NOW GET INFORMATION FROM TRACE/CHANNEL LEVEL FOR FIRST SWEEP OF EACH
% RECORDING
TimeUnit{iR,:}= {Recs(iR).Sweeps(1).Traces(:).TrXUnit};
ChUnit{iR,:} = {Recs(iR).Sweeps(1).Traces(:).TrYUnit};

RecModeID{iR,:} = [Recs(iR).Sweeps(1).Traces(:).TrRecordingMode];
RecordingMode{iR,:} = reshape(RecModeNames(RecModeID{iR}+1),1,numel(RecModeID{iR,:}));

ExternalSolutionID{iR,:} = [Recs(iR).Sweeps(1).Traces(:).TrExternalSolution];
InternalSolutionID{iR,:} = [Recs(iR).Sweeps(1).Traces(:).TrInternalSolution];

end






%%
% % FIND RECORDINGS IN THIS EXPERIMENT GROUP
% recIDs = find(~cellfun(@isempty,tree(:,3)));
% recIDs = recIDs(recIDs>thisExpID & recIDs<nextExpID);
% nRecs = numel(recIDs);
% 
% 
% ExperimentName = repmat(tree{thisExpID,2}.GrLabel,nRecs,1);
% ExperimentNumber = repmat(ExpNum,nRecs,1);
% recNum = reshape(1:nRecs,nRecs,1);
% 
% % GET RECORDINGS OF THIS EXPERIMENT
% Recs = [tree{recIDs,3}];
% 
% %EXTRACT INFORMATION FROM LEVEL 3
% Stimulus = reshape({Recs(:).SeLabel},numel(Recs),1);
% comment = reshape({Recs(:).SeComment},numel(Recs),1);
% nSweeps = reshape([Recs(:).SeNumbersw],numel(Recs),1);
% 
% %EXTRACT INFORMATION FROM AMPLIFIER STATE, LEVEL 3
% AmpState = [Recs(:).SeAmplifierState];
% Rs_uncomp = reshape(1./[AmpState(:).E9GSeries],numel(AmpState),1);
% Rs = Rs_uncomp - reshape([AmpState(:).E9RsValue],numel(AmpState),1);
% Cm = reshape([AmpState(:).E9CSlow],numel(AmpState),1);
% RsFractionComp = reshape([AmpState(:).E9RsFraction],numel(AmpState),1);
% Vhold = reshape([AmpState(:).E9VHold],numel(AmpState),1);
% 
% % FOR NOW ASSUME SWEEP INFORMATION AND CHANNEL INFORMATION ARE NOT CHANGING
% % BETWEEN SWEEPS
% 
% % EXTRACT RECORDING TEMPERATURE FROM SERIES/SWEEP, LEVEL 4
% SweepStruct = [tree{recIDs+1,4}];
% Temperature = reshape([SweepStruct(:).SwTemperature],numel(SweepStruct),1);
% 
% %EXTRACT INFORMATION FROM TRACE, LEVEL 5
% % FIND ALL CHANNELS BUT ONLY EXTRACT INFORMATION FROM FIRST SWEEP
% sweepIDs = recIDs+1;
% 
% startTr = sweepIDs; endTr = [recIDs(2:end)-1;size(tree,1)];
% 
% xUnit = cell(nRecs,1);
% yUnit = cell(nRecs,1);
% RecModeID = cell(nRecs,1);
% ExternalSolution = cell(nRecs,1);
% InternalSolution = cell(nRecs,1);
% 
% RecModeNames = {'inside-out V-clamp','on-cell V-clamp','outside-out V-clamp','Whole-cell V-clamp','C-clamp'};
% 
% for iRec = 1:numel(recIDs)
%     TraceStruct = [tree{startTr(iRec):endTr(iRec),5}];
%     xUnit{iRec} = {TraceStruct(:).TrXUnit};
%     yUnit{iRec} = {TraceStruct(:).TrYUnit};
%     RecModeID{iRec} = {TraceStruct(:).TrRecordingMode};
%     ExternalSolution{iRec} = {TraceStruct(:).TrExternalSolution};
%     InternalSolution{iRec} = {TraceStruct(:).TrInternalSolution};
%     
% end
% 
% % TraceStruct = [tree{recIDs+2,5}];
% % xUnit = reshape([TraceStruct(:).TrXUnit],numel(TraceStruct),1);
% % yUnit = reshape([TraceStruct(:).TrYUnit],numel(TraceStruct),1);
% % RecModeID = reshape([TraceStruct(:).TrRecordingMode],numel(TraceStruct),1);
% % ExternalSolution = reshape([TraceStruct(:).TrExternalSolution],numel(SweepStruct),1);
% % InternalSolution = reshape([TraceStruct(:).TrInternalSolution],numel(SweepStruct),1);
% 
% RecordingMode = reshape(RecModeNames(RecModeID+1),numel(RecModeID),1);


RecTab = table(ExperimentNumber,...
    ExperimentName,...
    recNum,...
    Rs,...
    Cm,...
    nSweeps,...
    Vhold,...
    Rs_uncomp,...
    RsFractionComp,...
    Stimulus,...
    TimeUnit,...
    ChUnit,...
    comment,...
    RecordingMode,...
    Temperature,...
    ExternalSolutionID,...
    InternalSolutionID,...
    'VariableNames',{'Experiment','ExperimentName','Rec','Rs','Cm','nSweeps','Vhold','Rs_uncomp','RsFractionComp','Stimulus','TimeUnit','ChUnit','comment','RecMode','Temperature','ExternalSolution','InternalSolution'});




end


function Sweeps = ImportSweeps(tree)

sweepIDs = find(~cellfun(@isempty,tree(:,1)));
traceSt = sweepIDs+1;

if numel(sweepIDs)>1
    traceEnd = [sweepIDs(2:end)-1;size(tree,1)];
else
    traceEnd = size(tree,1);
end

for iS = 1:numel(sweepIDs)
    Sweeps(iS) = tree{sweepIDs(iS),1};  
    Sweeps(iS).Traces = [tree{traceSt(iS):traceEnd(iS),2}];    
end



end




