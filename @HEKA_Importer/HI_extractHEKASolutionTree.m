function HI_extractHEKASolutionTree(obj,solTree)

% load('C:\Users\keineC\Documents\MATLAB\tree','tree')

%1: Root
%2 Solution
%3: Chemicals


if size(solTree,2) > 1 % OTHERWISE NOT SOLUTIONS DEFINED


% FIND NUMBER OF SOLUTIONS AND INDICES
sInd=find(~cellfun(@isempty,solTree(:,2)));
nSolutions = numel(sInd);

% GET SOLUTION NAMES AND NUMBER OF CHEMICALS PER SOLUTION
sols = [solTree{sInd,2}];
sNames = matlab.lang.makeValidName(reshape({sols(:).SoName},numel(sols),1));
sNumber =reshape([sols(:).SoNumber],numel(sols),1);

nChPerSol = diff([sInd;numel(solTree(:,2))+1])-1;


for iS = 1:nSolutions
    % FIND CHEMICALS FOR THIS SOLUTION
    chems = [solTree{sInd(iS)+1:sInd(iS)+nChPerSol(iS),3}];
% GET ALL CHEMICAL NAMES AND CONCENTRATIONS
    cNames = reshape({chems(:).ChName},numel(chems),1);
    cConcentration = reshape({chems(:).ChConcentration},numel(chems),1);


    obj.solutions.(sNames{iS}) = table(cNames,cConcentration,'VariableNames',{'Chemical','Concentration'});
    
%     obj.RecTable.InternalSolution = sNames(obj.RecTable.InternalSolution);

end
%% ASSIGN SOLUTION NAMES TO SOLUTION NUMBERS FROM RECORDINGS IN RECTABLE

obj.RecTable.ExternalSolution = sNames(sNumber(obj.RecTable.ExternalSolution));
obj.RecTable.InternalSolution = sNames(sNumber(obj.RecTable.InternalSolution));


else % USE NANs TO OVERWRITE THE STANDARD 0
obj.RecTable.ExternalSolution = NaN(size(obj.RecTable.ExternalSolution));
obj.RecTable.InternalSolution =  NaN(size(obj.RecTable.InternalSolution));
    
    
end



end













