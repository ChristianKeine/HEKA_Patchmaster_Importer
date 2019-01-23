function solutions=HI_extractHEKASolutionTree(obj,solTree)

ind = ~cellfun(@isempty,solTree);


%1: Root
%2 Solution
%3: Chemicals

solutions = [];

if size(solTree,2) > 1 % otherwise, no solutions defined

% FIND NUMBER OF SOLUTIONS AND INDICES
sInd=find(ind(:,2));
nSolutions = numel(sInd);

for iS = 1:nSolutions % CYCLE THROUGH SOLUTIONS AND EXTRACT CHEMICAL NAME AND CONCENTRATION
    if iS<nSolutions
        chemicalInd = sInd(iS)+1:sInd(iS+1)-1;
    else
        chemicalInd = sInd(iS)+1:size(solTree,1);
    end
    nChemicals = numel(chemicalInd);
    sName = matlab.lang.makeValidName(solTree{sInd(iS),2}.SoName);
    solutions.(sName) = table(string(NaN(nChemicals,1)),NaN(nChemicals,1),'VariableNames',{'Chemical','Concentration'});
    
    for iC = 1:nChemicals
        solutions.(sName).Chemical(iC) = solTree{chemicalInd(iC),3}.ChName;
        solutions.(sName).Concentration(iC) = solTree{chemicalInd(iC),3}.ChConcentration;
    end
    
    
end



end



end













