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
nChPerSol = diff([sInd;numel(solTree(:,2))+1])-1;


for iS = 1:nSolutions
    % FIND CHEMICALS FOR THIS SOLUTION
    chems = [solTree{sInd(iS)+1:sInd(iS)+nChPerSol(iS),3}];

% GET ALL CHEMICAL NAMES AND CONCENTRATIONS
    cNames = reshape({chems(:).ChName},numel(chems),1);
    cConcentration = reshape({chems(:).ChConcentration},numel(chems),1);


    obj.solutions.(sNames{iS}) = table(cNames,cConcentration,'VariableNames',{'Chemical','Concentration'});

end

end

% for iS = 1:nSolutions % CYCLE THROUGH SOLUTIONS AND EXTRACT CHEMICAL NAME AND CONCENTRATION
%     if iS<nSolutions
%         chemicalInd = sInd(iS)+1:sInd(iS+1)-1;
%     else
%         chemicalInd = sInd(iS)+1:size(solTree,1);
%     end
%     nChemicals = numel(chemicalInd);
%     sName = matlab.lang.makeValidName(solTree{sInd(iS),2}.SoName);
%     solutions.(sName) = table(string(NaN(nChemicals,1)),NaN(nChemicals,1),'VariableNames',{'Chemical','Concentration'});
%     
%     for iC = 1:nChemicals
%         solutions.(sName).Chemical(iC) = solTree{chemicalInd(iC),3}.ChName;
%         solutions.(sName).Concentration(iC) = solTree{chemicalInd(iC),3}.ChConcentration;
%     end
%     
%     
% end





end













