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

obj.RecTable = vertcat(Rt{:});


% numExperiment = numel(allExp);
% allRec = [find(ind(:,3));Inf];
% allTrace = [find(ind(:,4));Inf];
% 
% 
% for iExp=2:numExperiment
%  
% % find all recordings belonging to certain Exp.
% recPos{iExp-1,:} = allRec(allRec>allExp(iExp-1) & allRec<allExp(iExp));
% recPos{iExp-1,:} = [recPos{iExp-1};Inf];    
% 
% % find all sweeps per recording
%     for iRec = 2:numel(recPos{iExp-1})
%          sweepPos{iExp-1,:}{iRec-1,:} = allTrace(allTrace>recPos{iExp-1}(iRec-1) & allTrace<recPos{iExp-1}(iRec) & allTrace<allExp(iExp));
%     end
%     recPos{iExp-1,:}(end) = [];
% 
% %     ExperimentName{i,:} = tree{allExp(iExp-1),2}.GrLabel;
%     
% end
% 
% % read out Rs-values and Cm
% ind = cell2mat(recPos);
% for i = 1:numel(ind)
% %     Rs(i,:) = tree{ind(i),3}.SeAmplifierState.E9RsValue/tree{ind(i),3}.SeAmplifierState.E9RsFraction - tree{ind(i),3}.SeAmplifierState.E9RsValue;
% %     Rs(i,:) = tree{ind(i),3}.SeAmplifierState.E9RsValue;
%     Rs_uncomp(i,:) = 1/tree{ind(i),3}.SeAmplifierState.E9GSeries;
%     Rs(i,:) = Rs_uncomp(i,:)-tree{ind(i),3}.SeAmplifierState.E9RsValue;
%     Cm(i,:) = tree{ind(i),3}.SeAmplifierState.E9CSlow;
%     RsFractionComp(i,:) = tree{ind(i),3}.SeAmplifierState.E9RsFraction;
%     Vhold(i,:) = tree{ind(i),3}.SeAmplifierState.E9VHold;
%     Stimulus{i,:} = tree{ind(i),3}.SeLabel;
%     xUnit{i,:} = tree{ind(i)+2,5}.TrXUnit;
%     yUnit{i,:} = tree{ind(i)+2,5}.TrYUnit;
%     comment{i,:} = tree{ind(i),3}.SeComment;
%     switch tree{ind(i)+2,5}.TrRecordingMode
%         case 0
%             RecMode ='inside-out V-clamp';
%         case 1
%             RecMode = 'on-cell V-clamp';
%         case 2
%             RecMode = 'outside-out V-clamp';
%         case 3
%             RecMode = 'Whole-cell V-clamp';
%         case 4
%             RecMode = 'C-clamp';
% %             Rs = NaN;
% %             Cm = NaN;
% %             Rs_uncomp = NaN;
%     end
%     RecordingMode{i,:} = RecMode;
% end
% Rs = Rs*u.Ohm;
% Cm = Cm*u.F;
% Vhold = Vhold*u.V;
% Rs_uncomp = Rs_uncomp*u.Ohm;
% 
% % compile information over number of sweeps/recordings/experiments
% numExp = numel(sweepPos);
% % numExp = 
% for iExp = 1:numExp
%    numRecs = numel(sweepPos{iExp});
%    eN{iExp,:} = repmat(iExp,numel(sweepPos{iExp}),1);
%     for iRec = 1:numRecs
%     numSweeps{iExp,:}(iRec,:) = numel(sweepPos{iExp}{iRec});
% %     t = [t;[iExp,iRec,numSweeps,Rs/u.Ohm,]];
%      end
% end
%    
% % create table for IGOR macro input
% 
% t = table(cell2mat(eN),...
%     ExperimentName,...
%     transpose(1:numel(cell2mat(eN))),...
%     Rs/u.Ohm,...
%     Cm/u.F,...
%     cell2mat(numSweeps),...
%     Vhold/u.V,...
%     Rs_uncomp/u.Ohm,...
%     RsFractionComp,...
%     Stimulus,...
%     xUnit,...
%     yUnit,...
%     comment,...
%     RecordingMode,...
%     'VariableNames',{'Experiment','ExperimentName','Rec','Rs','Cm','nSweeps','Vhold','Rs_uncomp','RsFractionComp','Stimulus','xUnit','yUnit','comment','RecMode'});
% t.Rs(t.Rs==0) = 'uncompensated';
% num2clip(table2array(t))

%  num2clip([t.Rec,t.Rs,t.Cm,t.nSweeps]);
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

%EXTRACT INFORMATION FROM TRACE, LEVEL 5
TraceStruct = [tree{recIDs+2,5}];
xUnit = reshape([TraceStruct(:).TrXUnit],numel(TraceStruct),1);
yUnit = reshape([TraceStruct(:).TrYUnit],numel(TraceStruct),1);
RecModeID = reshape([TraceStruct(:).TrRecordingMode],numel(TraceStruct),1);
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
    'VariableNames',{'Experiment','ExperimentName','Rec','Rs','Cm','nSweeps','Vhold','Rs_uncomp','RsFractionComp','Stimulus','xUnit','yUnit','comment','RecMode'});




end







