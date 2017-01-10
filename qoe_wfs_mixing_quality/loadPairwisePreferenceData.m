function [prefMatArray,condGroupIdArray,probMatArray] = loadPairwisePreferenceData()

% load merged perceptual data
data = csvread('listening_test_results.txt');

% for your info: colum IDs
%  1: 'id'
%  2: 'TrialNumber'
%  3: 'StimID_1' => stimulus A
%  4: 'StimID_2' => stimulus B
%  5: 'Level'
%  6: 'Level.1'
%  7: 'Group'
%  8: 'Group.1'
%  9: 'Choice'
% 10: 'Switches'
% 11: 'ResponseTime'


% add stimuli IDs +1 for easier access/identification/etc
data(:,3:4) = data(:,3:4)+1;
% add group IDs +1 for easier access/identification/etc
data(:,7:8) = data(:,7:8)+1;

numCond = max(data(:,3));

% correct two individual wrong entries for stimID
data(1138,3) = 19;
data(2355,3) = 19;

% define which conditions belong to which group, in format needed for output
condGroupIdArray{1}(1:2) = 0;   % wfs_ref & stereo belong to all groups
condGroupIdArray{1}(3:5) = 1;   % group 1: compression
condGroupIdArray{1}(6:8) = 2;   % group 2: equalization
condGroupIdArray{1}(9:11) = 3;  % group 3: reverb
condGroupIdArray{1}(12:15) = 4; % group 4: positioning
condGroupIdArray{1}(16:18) = 5; % group 5: vocals
condGroupIdArray{1}(19) = -1;   % ignore


% compute total preference data per condition
% interpretation: 
% condition of row a is x-times prefered over condition in column b 
prefMatTotal = zeros(numCond,numCond);
numObsMat = zeros(numCond,numCond);
for condIdx1 = 1 : numCond
    for condIdx2 = 1 : numCond
        curObsAB = find( (data(:,3)==condIdx1) & (data(:,4)==condIdx2) );
        curObsBA = find( (data(:,3)==condIdx2) & (data(:,4)==condIdx1) );
        counterAB = length(curObsAB)-sum(data(curObsAB,9) ); % entries = 1 in column choice mean stimulus of condIdx2 is preferred => total number of curObs - sum of those entries
        counterBA = sum(data(curObsBA,9) ); % entries = 1 in column choice means stimulus of condIdx1 is preferred
        prefMatTotal(condIdx1,condIdx2) = counterAB + counterBA;
        numObsMat(condIdx1,condIdx2)    = length(curObsAB);
    end
end
% store prefMatTotal to output
prefMatArray{1} = prefMatTotal;

% preference matrices per condition group
%numGroups = max(data(:,7)); % overwrite this one because in data is a group 6 with mixed(?) conditions
numGroups = 5;
prefMatCondGroup = {};
for groupIdx = 1 : numGroups

    % define which conditions belong to which group, format needed here
    switch groupIdx
        case 1
            condOfGrpIdx = 1:5;
        case 2
            condOfGrpIdx = [1:2, 6:8];
        case 3
            condOfGrpIdx = [1:2, 9:11];
        case 4
            condOfGrpIdx = [1:2, 12:15];
        case 5
            condOfGrpIdx = [1:2, 16:18]; % 19]; % ignore condition 19
        otherwise
    end
    
    % define which conditions belong to which group, in format needed for output
    if groupIdx == 4
        condGroupIdArray{groupIdx+1}(1:6) = groupIdx;
    else
        condGroupIdArray{groupIdx+1}(1:5) = groupIdx;
    end
    
    % fill preference matrix for current group using total preference matrix
    prefMatArray{groupIdx+1}(1:length(condOfGrpIdx),1:length(condOfGrpIdx)) = prefMatTotal(condOfGrpIdx,condOfGrpIdx);
    
    % special treatment of comparison cond1 (ref) vs. cond2 (stereo)
    % do this per condition group, defined in data column 7 (& 8),
    % instead of simply reading from perfMatTotal
    prefMatCond1Cond2 = zeros(2,2);
    for condIdx1 = 1 : 2
        for condIdx2 = 1 : 2
            curObsAB = find( (data(:,3)==condIdx1) & (data(:,4)==condIdx2) & (data(:,7)==groupIdx) );
            curObsBA = find( (data(:,3)==condIdx2) & (data(:,4)==condIdx1) & (data(:,7)==groupIdx) );
            counterAB = length(curObsAB)-sum(data(curObsAB,9) );
            counterBA = sum(data(curObsBA,9) );
            prefMatCond1Cond2(condIdx1,condIdx2) = counterAB + counterBA;
        end
    end
    prefMatArray{groupIdx+1}(1:2,1:2) = prefMatCond1Cond2;
    
end

for runIdx = 1 : length(prefMatArray)
    curPrefMat = prefMatArray{runIdx};
    a = size(curPrefMat,1);
    curProbMat = zeros(a,a);
    for condIdx1 = 1 : a-1
        for condIdx2 = condIdx1 + 1 : a
            b = sum(curPrefMat(condIdx1,condIdx2) + curPrefMat(condIdx2,condIdx1));
            if b > 0
                curProbMat(condIdx1,condIdx2) = curPrefMat(condIdx1,condIdx2) / b;
            end
        end
    end
    probMatArray{runIdx} = curProbMat;
end
