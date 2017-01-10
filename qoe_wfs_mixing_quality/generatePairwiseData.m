function [featureData,classLabels,classProb,condGroupData,subjGroupData] = generatePairwiseData(prefMat,condGroupIDs,featureDataIn)


numCond       = size(prefMat,1);
featureData   = [];
classLabels   = [];
classProb     = [];
condGroupData = [];
subjGroupData = []; % here not really subjects, but used to link features and their inverted features
subjID = 0;         % needed for filling subjGroupData

for condIdx1 = 1 : numCond-1
    for condIdx2 = condIdx1 + 1 : numCond
        
        % 1. compute delta feature vectors Fd_xy for each song pair Sx Sy
        %    note: also add "inverted" features
        featureData = [featureData; ...
            featureDataIn(condIdx1,:) - featureDataIn(condIdx2,:); ...
            featureDataIn(condIdx2,:) - featureDataIn(condIdx1,:)];
        
        % 2. assign binary classes depending on pairwise preference pref(Sx,Sy) for Song Sx compared to Song Sy
        %    note: also add inverted class labels for inverted features
        curPrefxy = prefMat(condIdx1,condIdx2);
        curPrefyx = prefMat(condIdx2,condIdx1);
        if curPrefxy > curPrefyx
            classLabels = [classLabels; 1; -1];
        elseif curPrefxy < curPrefyx
            classLabels = [classLabels; -1; 1];
        else
            classLabels = [classLabels; 0; 0];
        end
        
        % 3. construct class "probabilities" as n-by-2 matrix, 
        % with columns consistent to classification toolbox conventions
        % => column 1: probability of negative class ("not prefered")
        %    column 2: probability of positive class ("prefered")
        %    note: again add inverted probabilities for inverted features
        classProb = [classProb; ...
            curPrefyx/(curPrefxy+curPrefyx) curPrefxy/(curPrefxy+curPrefyx); ...
            curPrefxy/(curPrefxy+curPrefyx) curPrefyx/(curPrefxy+curPrefyx)];
        
        % 4. get information to which condition groups the two compared conditions belong
        %    note: again add inverted information for inverted features
        condGroupData = [condGroupData; ...
            condGroupIDs(condIdx1), condGroupIDs(condIdx2); ...
            condGroupIDs(condIdx2), condGroupIDs(condIdx1)];
        
        % 5. get information which feature vectors are linked, i.e.
        % non-inverted & inverted, used concept of subject ID
        subjID = subjID + 1;
        subjGroupData = [subjGroupData; subjID; subjID];
    end
end

% remove all observations with class label 0
validObs      = find(classLabels ~= 0);
featureData   = featureData(validObs,:);
classLabels   = classLabels(validObs,:);
classProb     = classProb(validObs,:);
condGroupData = condGroupData(validObs,:);
subjGroupData = subjGroupData(validObs,:);