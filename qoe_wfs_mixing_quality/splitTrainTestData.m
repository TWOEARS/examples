function [trainData, testData, trainTestSplitStats] = splitTrainTestData(inData,groupingID,subsetID,condID,proportion,seed)

% Function to split data into training and test. 
% Based on scripts originally developed for a
% PhD thesis [Janto Skowronek, "Quality of Experience of Multiparty
% Conferencing and Telemeeting Systems - Methods and Models for Assessment
% and Prediction", defended in 2016, to be published]


% set default values
if nargin < 6
    seed = [];
end
if isempty(seed)
    % none-repeatable randomization
    seed = now;
end

if nargin < 5
    proportion = [];
end
if isempty(proportion)
    proportion = 0.8;
end

if nargin < 4
    condID = [];
end
if isempty(condID)
    % all to same condition
    condID = ones(size(inData,1),1);
end

if nargin < 3
    subsetID = [];
end
if isempty(subsetID)
    % all to same subset
    subsetID = ones(size(inData,1),1);
end

if nargin < 2
    groupingID = [];
end
if isempty(groupingID)
    % all individual observations
    groupingID = (1:size(inData,1))';
end

% set state of random number generator
rng(seed);

% helper variables
numObs = size(inData,1);

% insert randomization by random sorting
resortVec = randperm(numObs);
inData = inData(resortVec,:);
groupingID = groupingID(resortVec);
subsetID = subsetID(resortVec);
condID = condID(resortVec);

% helper variables for assignment per subset and condition
numSubsets = max(subsetID);
numCond    = max(condID);
numObsSubsetCond = zeros(numSubsets,numCond);
for subsetIdx = 1 : numSubsets
    for condIdx = 1 : numCond
        numObsSubsetCond(subsetIdx,condIdx) = sum ( (subsetID==subsetIdx) & (condID==condIdx) );
    end
end
numObsSubsetCondTrain    = zeros(numSubsets,numCond);
maxNumObsSubsetCondTrain = round(proportion * numObsSubsetCond);
numObsSubsetCondTest     = zeros(numSubsets,numCond);
maxNumObsSubsetCondTest  = numObsSubsetCond - maxNumObsSubsetCondTrain;

% prepare to go through subsets/cond with ascending size of those groups
% background: smallest groups have least freedom => minimizes risk of
% violating boundary conditions (proportion per subset and condition)
subsetIDMat = repmat((1:numSubsets)',1,numCond);
condIDMat   = repmat(1:numCond,numSubsets,1);
numObsSubsetCondVec = numObsSubsetCond(:);
subsetIDVec = subsetIDMat(:);
condIDVec   = condIDMat(:);
tempIdx = find(numObsSubsetCondVec);
numObsSubsetCondVec = numObsSubsetCondVec(tempIdx);
subsetIDVec = subsetIDVec(tempIdx);
condIDVec   = condIDVec(tempIdx);
[numObsSubsetCondVec,pos] = sort(numObsSubsetCondVec);
subsetIDVec = subsetIDVec(pos);
condIDVec   = condIDVec(pos);

trainID = zeros(numObs,1);
testID  = zeros(numObs,1);

% run through subsets/conditions
for subsetCondIdx = 1 : length(numObsSubsetCondVec)
    
    curObs    = find( (subsetID==subsetIDVec(subsetCondIdx)) & (condID==condIDVec(subsetCondIdx)) );
    numCurObs = length(curObs);
    
    % run through observations
    if numCurObs > 2
        
        for curObsIdx = 1 : numCurObs
            
            obsIdx = curObs(curObsIdx);
            
            % check if assignment needs to be done
            if (trainID(obsIdx)==0) && (testID(obsIdx)==0)
                
                newNumObsSubsetCondTrain = estNewNumObsSubsetCondTx(numObsSubsetCondTrain,groupingID,subsetID,condID,obsIdx);
                newNumObsSubsetCondTest  = estNewNumObsSubsetCondTx(numObsSubsetCondTest,groupingID,subsetID,condID,obsIdx);
                
                trainAllowed = checkTxAllowed(newNumObsSubsetCondTrain,maxNumObsSubsetCondTrain);
                testAllowed  = checkTxAllowed(newNumObsSubsetCondTest, maxNumObsSubsetCondTest);
                
                if trainAllowed && testAllowed
                    % make a randomized decision
                    randVal = rand;
                    if randVal <= proportion
                        % go for training
                        trainID = assignToTx(trainID,groupingID,obsIdx);
                        numObsSubsetCondTrain = newNumObsSubsetCondTrain;
                    else
                        % go for test
                        testID = assignToTx(testID,groupingID,obsIdx);
                        numObsSubsetCondTest = newNumObsSubsetCondTest;
                    end
                    
                elseif trainAllowed && ~testAllowed
                    % go for training
                    trainID = assignToTx(trainID,groupingID,obsIdx);
                    numObsSubsetCondTrain = newNumObsSubsetCondTrain;
                    
                elseif ~trainAllowed && testAllowed
                    % go for test
                    testID = assignToTx(testID,groupingID,obsIdx);
                    numObsSubsetCondTest = newNumObsSubsetCondTest;
                    
                elseif ~trainAllowed && ~testAllowed
                    % boundary conditions violated
                    % => choose option with smallest error
                    trainError = getTxError(newNumObsSubsetCondTrain,maxNumObsSubsetCondTrain);
                    testError  = getTxError(newNumObsSubsetCondTest,maxNumObsSubsetCondTest);
                    if trainError < testError
                        % go for training
                        trainID = assignToTx(trainID,groupingID,obsIdx);
                        numObsSubsetCondTrain = newNumObsSubsetCondTrain;
                    elseif testError <= trainError
                        % go for test
                        testID = assignToTx(testID,groupingID,obsIdx);
                        numObsSubsetCondTest = newNumObsSubsetCondTest;
                    end
                    
                end
                
            end
            
        end
    elseif numCurObs == 2
        
        % force one observation to train and one to test
        if ((trainID(curObs(1))==0) && (testID(curObs(1))==0)) && ((trainID(curObs(2))==0) && (testID(curObs(2))==0))
            % choose options with smallest error
            newNumObsSubsetCondTrain1 = estNewNumObsSubsetCondTx(numObsSubsetCondTrain,groupingID,subsetID,condID,curObs(1));
            newNumObsSubsetCondTest1  = estNewNumObsSubsetCondTx(numObsSubsetCondTest,groupingID,subsetID,condID,curObs(1));            
            newNumObsSubsetCondTrain2 = estNewNumObsSubsetCondTx(numObsSubsetCondTrain,groupingID,subsetID,condID,curObs(1));
            newNumObsSubsetCondTest2  = estNewNumObsSubsetCondTx(numObsSubsetCondTest,groupingID,subsetID,condID,curObs(1));            
            trainError1 = getTxError(newNumObsSubsetCondTrain1,maxNumObsSubsetCondTrain);
            testError1  = getTxError(newNumObsSubsetCondTest1,maxNumObsSubsetCondTest);
            trainError2 = getTxError(newNumObsSubsetCondTrain2,maxNumObsSubsetCondTrain);
            testError2  = getTxError(newNumObsSubsetCondTest2,maxNumObsSubsetCondTest);
            if (trainError1 + testError2) <= (testError1 + trainError2)
                % first training, second test
                trainID = assignToTx(trainID,groupingID,curObs(1));
                numObsSubsetCondTrain = newNumObsSubsetCondTrain1;
                testID = assignToTx(testID,groupingID,curObs(2));
                numObsSubsetCondTest = newNumObsSubsetCondTest2;
            elseif (trainError1 + testError2) > (testError1 + trainError2)
                % first test, second training
                trainID = assignToTx(trainID,groupingID,curObs(2));
                numObsSubsetCondTrain = newNumObsSubsetCondTrain2;
                testID = assignToTx(testID,groupingID,curObs(1));
                numObsSubsetCondTest = newNumObsSubsetCondTest1;
            end
        elseif  ((trainID(curObs(1))==0) && (testID(curObs(1))==0)) && ~((trainID(curObs(2))==0) && (testID(curObs(2))==0))
            % choose option with smallest error
            newNumObsSubsetCondTrain1 = estNewNumObsSubsetCondTx(numObsSubsetCondTrain,groupingID,subsetID,condID,curObs(1));
            newNumObsSubsetCondTest1  = estNewNumObsSubsetCondTx(numObsSubsetCondTest,groupingID,subsetID,condID,curObs(1));
            trainError1 = getTxError(newNumObsSubsetCondTrain1,maxNumObsSubsetCondTrain);
            testError1  = getTxError(newNumObsSubsetCondTest1,maxNumObsSubsetCondTest);
            if trainError1 <= testError1
                % training
                trainID = assignToTx(trainID,groupingID,curObs(1));
                numObsSubsetCondTrain = newNumObsSubsetCondTrain1;
            elseif trainError1 > testError1
                % test
                testID = assignToTx(testID,groupingID,curObs(1));
                numObsSubsetCondTest = newNumObsSubsetCondTest1;
            end
        elseif ~((trainID(curObs(1))==0) && (testID(curObs(1))==0)) &&  ((trainID(curObs(2))==0) && (testID(curObs(2))==0))
            % choose option with smallest error
            newNumObsSubsetCondTrain2 = estNewNumObsSubsetCondTx(numObsSubsetCondTrain,groupingID,subsetID,condID,curObs(1));
            newNumObsSubsetCondTest2  = estNewNumObsSubsetCondTx(numObsSubsetCondTest,groupingID,subsetID,condID,curObs(1));            
            trainError2 = getTxError(newNumObsSubsetCondTrain2,maxNumObsSubsetCondTrain);
            testError2  = getTxError(newNumObsSubsetCondTest2,maxNumObsSubsetCondTest);
            if trainError2 <= testError2
                % training
                trainID = assignToTx(trainID,groupingID,curObs(2));
                numObsSubsetCondTrain = newNumObsSubsetCondTrain2;
            elseif trainError2 > testError2
                % test
                testID = assignToTx(testID,groupingID,curObs(2));
                numObsSubsetCondTest = newNumObsSubsetCondTest2;
            end
        end
    elseif numCurObs == 1
        if ((trainID(curObs(1))==0) && (testID(curObs(1))==0))
            % choose option with smallest error
            newNumObsSubsetCondTrain1 = estNewNumObsSubsetCondTx(numObsSubsetCondTrain,groupingID,subsetID,condID,curObs(1));
            newNumObsSubsetCondTest1  = estNewNumObsSubsetCondTx(numObsSubsetCondTest,groupingID,subsetID,condID,curObs(1));
            trainError1 = getTxError(newNumObsSubsetCondTrain1,maxNumObsSubsetCondTrain);
            testError1  = getTxError(newNumObsSubsetCondTest1,maxNumObsSubsetCondTest);
            if trainError1 <= testError1
                % training
                trainID = assignToTx(trainID,groupingID,curObs(1));
                numObsSubsetCondTrain = newNumObsSubsetCondTrain1;
            elseif trainError1 > testError1
                % test
                testID = assignToTx(testID,groupingID,curObs(1));
                numObsSubsetCondTest = newNumObsSubsetCondTest1;
            end
        end
    end
end

% revert randomization of order
trainIDout  = zeros(numObs,1);
testIDout   = zeros(numObs,1);
subsetIDout = zeros(numObs,1);
condIDout   = zeros(numObs,1);
for runIdx = 1 : numObs
    trainIDout(resortVec(runIdx),1)  = trainID(runIdx);
    testIDout(resortVec(runIdx),1)   = testID(runIdx);
    subsetIDout(resortVec(runIdx),1) = subsetID(runIdx);
    condIDout(resortVec(runIdx),1)   = condID(runIdx);
end

% produce training and test data sets
trainData = inData(trainIDout==1,:);
testData  = inData(testIDout==1,:);

% produce logs and statistics
trainTestSplitStats.trainID = trainIDout;
trainTestSplitStats.testID  = testIDout;
trainTestSplitStats.numObsSubsetCond      = numObsSubsetCond;
trainTestSplitStats.numObsSubsetCondTrain = numObsSubsetCondTrain;
trainTestSplitStats.numObsSubsetCondTest  = numObsSubsetCondTest;

trainTestSplitStats.proportionTarget = proportion;
trainTestSplitStats.proportionReal   = sum(trainIDout)/numObs;

x = sort(subsetIDout(find(trainIDout)))';
proportionPerSubset = zeros(numSubsets,1);
for subsetIdx = 1 : numSubsets
    proportionPerSubset(subsetIdx) = length(find(x==subsetIdx))/ sum(subsetIDout==subsetIdx) ;
end
trainTestSplitStats.proportionPerSubset = proportionPerSubset;

x = sort(condIDout(find(trainIDout)))';
proportionPerCond = zeros(numCond,1);
for condIdx = 1 : numCond
    proportionPerCond(condIdx) = length(find(x==condIdx))/sum(condIDout==condIdx);
end
trainTestSplitStats.proportionPerCond   = proportionPerCond;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub-functions

function newNumObsSubsetCondTx = estNewNumObsSubsetCondTx(numObsSubsetCondTx,groupingID,subsetID,condID,obsIdx)
% find all observations belonging to group
sameGroupIdx = find(groupingID == groupingID(obsIdx));
% increase counter
newNumObsSubsetCondTx = numObsSubsetCondTx;
for runIdx = 1 : length(sameGroupIdx)
    curSubset = subsetID(sameGroupIdx(runIdx));
    curCond   = condID(sameGroupIdx(runIdx));
    newNumObsSubsetCondTx(curSubset,curCond) = newNumObsSubsetCondTx(curSubset,curCond) + 1;
end

function txAllowed = checkTxAllowed(newNumObsSubsetCondTx,maxNumObsSubsetCondTx)
x = (newNumObsSubsetCondTx <= maxNumObsSubsetCondTx);
if sum(x(:)) == length(x(:))
    txAllowed = 1;
else
    txAllowed = 0;
end

function txOptID = assignToTx(txOptID,groupingID,obsIdx)
% find all observations belonging to group
sameGroupIdx = find(groupingID == groupingID(obsIdx));
% add those observations to Tx
txOptID(sameGroupIdx) = 1;

function txError = getTxError(newNumObsSubsetCondTx,maxNumObsSubsetCondTx)
x = (newNumObsSubsetCondTx <= maxNumObsSubsetCondTx);
txError = 1 - sum(x(:))/length(x(:));

