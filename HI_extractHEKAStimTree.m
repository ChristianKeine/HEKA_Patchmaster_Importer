function HI_extractHEKAStimTree(obj,stimTree)

% load('C:\Users\keineC\Documents\MATLAB\tree','tree')
% global u, if isempty(u), u = units; end
% ind = ~cellfun(@isempty,stimTree);

%1: Root
%2 Series
%3: channels
%4: segments


%find Series/Recordings

allRecs = find(~cellfun(@isempty,stimTree(:,2)));
% allChannels = find(~cellfun(@isempty,stimTree(:,3)));

% GET CHANNELS AND NUMBER OF SEGMENTS PER CHANNEl
Recs = [stimTree{allRecs,2}];
nRecs = numel(Recs);
STIM = cell(numel(Recs),1);

for iRec = 1:numel(Recs)
    if iRec == nRecs
        nextRec = Inf;
    else
        nextRec = allRecs(iRec+1);
    end
    STIM{iRec} = ImportStimulus(stimTree,allRecs(iRec),nextRec);
end

% nSegments = reshape([ch(:).chCRC],numel(ch),1);

% ADD STIMULUS TO RECORDING TABLE
obj.RecTable.stimWave = STIM;



% nRec
%
% for iRec=2:numel(allRecs)
%
% % cycle through recordings and find channels
% channelPos = allChannels(allChannels>allRecs(iRec-1) & allChannels<allRecs(iRec));
%
% for iCh=1:numel(channelPos)
%    nSegments = double(stimTree{channelPos(iCh),3}.chCRC);
%    segmentPos =  channelPos(iCh)+1:channelPos(iCh)+nSegments;
%    RecCh{iRec-1} = channelPos;
%    RecChSeg{iRec-1}{iCh} = segmentPos;
%
% end
% end
% % cycle through channels and reconstruct stimulus of all channels
%
%
% for iR=1:numel(RecCh)
%     clear STIM
%     SR = (1/stimTree{allRecs(iR),2}.stSampleInterval); % Hz
%
%     for iC=1:numel(RecCh{iR})
%
%
%     %determine channel type
%         switch stimTree{RecCh{iR}(iC),3}.chDacMode
%             case 1 % for DA channels
% %                 switch stimTree{RecCh{iR}(iC),3}.chDacChannel
% %                     case {0,1}
%                     currChName = ['DA_',n2s(stimTree{RecCh{iR}(iC),3}.chDacChannel)];
% %                     case 2
% %                     currChName = ['Stim_',n2s(stimTree{RecCh{iR}(iC),3}.chDacChannel)];
% %                     case 10
% %                     currChName = ['Test_DA'];
% %                     otherwise
% %                     currChName = ['unknownMode_DAC',n2s(stimTree{RecCh{iR}(iC),3}.chDacChannel)];
%
% %                 end
%             case 3 % for Dig channels
%                 currChName = ['Dig_',n2s(stimTree{RecCh{iR}(iC),3}.chDacBit)];
%             otherwise
%                 currChName = ['unknownMode_DAC',n2s(stimTree{RecCh{iR}(iC),3}.chDacChannel)];
%         end
%
% %     currChName = ['Ch',n2s(stimTree{RecCh{iR}(iC),3}.chCRC)];
% %     currChName = ['Ch',n2s(iC)];
%
%     numelSeg = numel(RecChSeg{iR}{iC});
% %     STIM.(currChName) = [];
%
%     %determine if segments or template mode
%     sMode = stimTree{RecCh{iR}(iC),3}.chStimToDacID;
%
%      nSweeps = double(stimTree{allRecs(iR),2}.stNumberSweeps);
%
%
%
%     switch sMode
%         case {0,1,32} %no template
%             for iSw=1:nSweeps
%     STIM.(currChName){iSw} = [];
%
%     for iS=1:numelSeg
%         clear seg;
%         durSeg = stimTree{RecChSeg{iR}{iC}(iS),4}.seDuration +(stimTree{RecChSeg{iR}{iC}(iS),4}.seDeltaTIncrement)*(iSw-1);
%         valSeg = stimTree{RecChSeg{iR}{iC}(iS),4}.seVoltage + (stimTree{RecChSeg{iR}{iC}(iS),4}.seDeltaVIncrement)*(iSw-1);
%         seg(1:round(durSeg*SR)) = valSeg;
%         STIM.(currChName){iSw} = [STIM.(currChName){iSw},seg];
%
%     end
%             end
% %         case 4 %template
% %             f=fields(ephysData);
% %         ind = contains(ephysData.(f{1}).channel(~cellfun(@isempty,ephysData.(f{1}).channel(:,iR)),iR),'Adc-0');
% %         STIM.(currChName) =  ephysData.(f{1}).data{ind,iR};
% % %         STIM.(currChName)(STIM.(currChName)<2) = 0;
% % %         STIM.(currChName)(STIM.(currChName)>4) = 5;
%     end
%    t.stimWave{iR} = STIM;
%
%     end
% end
% end
end



function STIM = ImportStimulus(stimTree,thisRecID,nextRecID)

% GET ALL CHANNELS OF THIS RECORDING
chIDs = find(~cellfun(@isempty,stimTree(:,3)));
chIDs = chIDs(chIDs>thisRecID & chIDs<nextRecID);
% nCh = numel(chIDs);
nSweeps = stimTree{thisRecID,2}.stNumberSweeps;

% GET SAMPLING RATE
SR = 1./stimTree{thisRecID,2}.stSampleInterval;

% GET STIMULUS SEGMENTS PER CHANNEL
ch = [stimTree{chIDs,3}];
nSegments = reshape([ch(:).chCRC],numel(ch),1);


% getAllSegments of this Recordings
% segStruct = find(~cellfun(@isempty,stimTree(:,4)));
% segStruct = segStruct(segStruct>thisRecID & segStruct<nextRecID);


%% EXTRACT STIMULUS SEGMENTS PER CHANNEL
for iC = 1:numel(ch)
    
    % GET CHANNEL NAME
    % TO DO: NEED TO FIGURE OUT HOW THOSE CODES RELATE TO ACTUAL CHANNELS
    sMode = ch(iC).chStimToDacID;
    DACMode = ch(iC).chDacMode;
    %ADCMode = ch(iC).chDacMode;
    DACBit = ch(iC).chDacBit;
    
    switch DACMode
        case 1
            chName = ['DA_',num2str(ch(iC).chDacChannel)];
        case 3
            chName = ['Dig_',num2str(ch(iC).chDacBit)];
        otherwise
            chName = ['unknownMode_DAC_',num2str(ch(iC).chDacChannel)];
    end
    
    
    
    
    % GET SEGMENTS
    segs = [stimTree{chIDs(iC)+1:chIDs(iC)+nSegments(iC),4}];
    
    % GET DURATION AND AMPLITUDE OF SEGMENTS
    segT = reshape([segs(:).seDuration],numel(segs),1);
    segV = reshape([segs(:).seVoltage],numel(segs),1);
    
    % GET CHANGES DURING SWEEPS
    % TO DO: IMPLEMENT DIFFERENT MODES (ALTERNATING ETC.) BUT NEED TEMPLATE
    % FIRST
    segDeltaT = reshape([segs(:).seDeltaTIncrement],numel(segs),1) .* reshape([segs(:).seDeltaTFactor],numel(segs),1);
    segDeltaV = reshape([segs(:).seDeltaVIncrement],numel(segs),1) .* reshape([segs(:).seDeltaVFactor],numel(segs),1);
    
    constantSegs = ~any([segDeltaT(:);segDeltaV(:)]);
    
    % DUPLICATE BASE SEGMENTS FOR MULTIPLE SWEETS
    segT = repmat(segT,1,nSweeps);
    segV = repmat(segV,1,nSweeps);
    segDeltaT = [zeros(size(segDeltaT)),repmat(segDeltaT,1,nSweeps-1)];
    segDeltaV = [zeros(size(segDeltaV)),repmat(segDeltaV,1,nSweeps-1)];
    
    % CHANGE MATRIX
    segT = segT + cumsum(segDeltaT,2);
    segV = segV + cumsum(segDeltaV,2);
    segTime = round(segT .* SR);
    
    
    % CREATE STIMULUS FOR EACH SWEEP UNLESS SWEEP PARAMETERS ARE CONSTANT
    
    % DEFINE MATRIX FOR STIMULI
    maxSweepDur = max(sum(segTime,1));
    stimMatrix = NaN(maxSweepDur,nSweeps);
    
    % CREATE STIMULUS VECTOR
    fun = @(segTime,segV) repmat(segV,[segTime,1]);
    stims = arrayfun(fun,segTime,segV,'UniformOutput',false);
    
    
    if ~constantSegs
        % SORT STIMULUS IN MATRIX
        for iS = 1:nSweeps
            stimMatrix(1:sum(segTime(:,iS)),iS) = cell2mat(stims(:,iS));
        end
        
    else
        stimMatrix = cell2mat(stims(:,1));
    end
    
    
    
    
    STIM.(chName) = stimMatrix;
    
    
    
    
end


end




