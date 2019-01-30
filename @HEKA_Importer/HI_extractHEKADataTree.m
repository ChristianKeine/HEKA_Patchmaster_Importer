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
       nextExp = Inf;
   else
       nextExp = allExp(iExp+1);
   end
   Rt{iExp} = ImportRecordings(tree,allExp(iExp),nextExp,iExp); 
end

obj.RecTable = [vertcat(Rt{:}),obj.RecTable];



end



function RecTab = ImportRecordings(tree,thisExpID,nextExpID,ExpNum)

% FIND RECORDINGS IN THIS EXPERIMENT GROUP
recIDs = find(~cellfun(@isempty,tree(:,3)));
recIDs = recIDs(recIDs>thisExpID & recIDs<nextExpID);
nRecs = numel(recIDs);


ExperimentName = repmat(tree{thisExpID,2}.GrLabel,nRecs,1);
ExperimentNumber = repmat(ExpNum,nRecs,1);
recNum = reshape(1:nRecs,nRecs,1);

% GET RECORDINGS OF THIS EXPERIMENT
Recs = [tree{recIDs,3}];

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

% EXTRACT RECORDING TEMPERATURE FROM SERIES, LEVEL 4
SweepStruct = [tree{recIDs+1,4}];
Temperature = reshape([SweepStruct(:).SwTemperature],numel(SweepStruct),1);

%EXTRACT INFORMATION FROM TRACE, LEVEL 5
TraceStruct = [tree{recIDs+2,5}];
xUnit = reshape([TraceStruct(:).TrXUnit],numel(TraceStruct),1);
yUnit = reshape([TraceStruct(:).TrYUnit],numel(TraceStruct),1);
RecModeID = reshape([TraceStruct(:).TrRecordingMode],numel(TraceStruct),1);
ExternalSolution = reshape([TraceStruct(:).TrExternalSolution],numel(SweepStruct),1);
InternalSolution = reshape([TraceStruct(:).TrInternalSolution],numel(SweepStruct),1);

RecModeNames = {'inside-out V-clamp','on-cell V-clamp','outside-out V-clamp','Whole-cell V-clamp','C-clamp'};
RecordingMode = reshape(RecModeNames(RecModeID+1),numel(RecModeID),1);


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
    xUnit,...
    yUnit,...
    comment,...
    RecordingMode,...
    Temperature,...,
    ExternalSolution,...
    InternalSolution,...
    'VariableNames',{'Experiment','ExperimentName','Rec','Rs','Cm','nSweeps','Vhold','Rs_uncomp','RsFractionComp','Stimulus','xUnit','yUnit','comment','RecMode','Temperature','ExternalSolution','InternalSolution'});




end







