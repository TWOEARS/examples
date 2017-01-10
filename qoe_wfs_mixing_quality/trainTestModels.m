function perfStruct = trainTestModels(inData,groupingID,subsetID,condID,proportion,numRep,funVec,saveRawFlag)

% Function to train and test classification models using a bootstrap-type 
% validation procedure. 
% Based on scripts originally developed for a
% PhD thesis [Janto Skowronek, "Quality of Experience of Multiparty
% Conferencing and Telemeeting Systems - Methods and Models for Assessment
% and Prediction", defended in 2016, to be published]

% selection of modeling functions, here: classifier type
if nargin < 7
    funVec = [];
end
if isempty(funVec)
    funVec = 1:3;
end

% parameters for train/test method
if nargin < 6
    numRep = [];
end
if nargin < 5
    proportion = [];
end
if isempty(numRep)
    numRep = 20;
end
if isempty(proportion)
    proportion = 0.8;
end

% definition of subsets
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


% groupingID = [];
% definition of data linking variable (i.e. do not split data of same subjects)
if nargin < 2
    groupingID = [];
end
if isempty(groupingID)
    % all individual observations
    groupingID = (1:size(inData,1))';
end

% define type of training:
% trainingType(x) = 1  => training on all data
% trainingType(x) = 2  => training per subset
% trainingType(x) = 3  => training per condition
% trainingType(x) = 4  => training per subset/condition
trainingType = 1:4;

% define type of testing
% testType(x) = 1  => test on all data
% testType(x) = 2  => test per subset
% testType(x) = 3  => test per condition
% testType(x) = 4  => test per subset/condition
testType = 1:4;

% output
% 
% training: compute optimal weights WijOpt per repetition
% four versions of training / weigts:
% WijOpt{1,repIdx} : training on all data 
% WijOpt{2,repIdx} : training per subset
% WijOpt{3,repIdx} : training per condition
% WijOpt{4,repIdx} : training per subset/condition
% 
% test: compute performance measures rx (= rho, rmse)
% 16 versions of testing 
% rx{testType,trainingType}
% => examples:
% rx{1,1} : test all data,   with training on all data
% rx{1,2} : test all data,   with training per subset
% rx{2,1} : test per subset, with training on all data
% rx{2,2} : test per subset, with training per subset

% create subset/condition combination using subsetID and condID
numCond   = max(condID);
subsetCondID = (subsetID-1)*numCond+condID;

% special case: testing different proportions, which is activated by
% propotion being a vector instead of a scalar
numSplit = length(proportion);

% split data into training and test sets, but here not actual data but indices
for repIdx = 1 : numRep
    for splitIdx = 1 : numSplit
        [~, ~, trainTestSplitStats{repIdx,splitIdx}] = splitTrainTestData(inData,groupingID,subsetID,condID,proportion(splitIdx),repIdx);
    end
end

% run through different splits
for splitIdx = 1 : numSplit

% run through functions
for funIdx = funVec
    disp(['running function F' num2str(funIdx)])
        
    % run through repetitions
    for repIdx = 1 : numRep
        disp(['    iteration ' num2str(repIdx) ' from ' num2str(numRep)])
            
        % A) split data into train and test data
        % get train and test data IDs
        trainID       = trainTestSplitStats{repIdx,splitIdx}.trainID;
        testID        = trainTestSplitStats{repIdx,splitIdx}.testID;
        % reinterpret trainId and testID
        trainID       = find(trainID == 1);
        testID        = find(testID  == 1);
        % get data
        trainData     = inData(trainID,:);
        testData      = inData(testID,:);
        % get subsetID
        trainSubsetID = subsetID(trainID);
        testSubsetID  = subsetID(testID);
        % get condID
        trainCondID   = condID(trainID);
        testCondID    = condID(testID);
        % get subsetCondID
        trainSubsetCondID = subsetCondID(trainID);
        testSubsetCondID  = subsetCondID(testID);
        
        % B) train model parameters
        % run through train groups (=all, subset, cond, subsetCond)
        for trainTypeIdx = trainingType
            switch trainTypeIdx
                case 1
                    numGroups = 1;
                case 2
                    numGroups = max(trainSubsetID);
                case 3
                    numGroups = max(trainCondID);
                case 4
                    numGroups = max(trainSubsetCondID);
            end
            for grIdx = 1 : numGroups
                switch trainTypeIdx
                    case 1
                        curTrainIdx = 1:size(trainData,1);
                    case 2
                        curTrainIdx = (find(trainSubsetID == grIdx));
                    case 3
                        curTrainIdx = (find(trainCondID == grIdx));
                    case 4
                        curTrainIdx = (find(trainSubsetCondID == grIdx));
                end
                QicTrain = trainData(curTrainIdx,1);
                QijTrain = trainData(curTrainIdx,2:end);
                WijOpt{trainTypeIdx,repIdx,splitIdx}{funIdx,grIdx} = trainFx(QicTrain,QijTrain,funIdx);
            end
        end % end of training
        
        % C) test models
        % run through test and train types
        for testTypeIdx = testType
            for trainTypeIdx = trainingType
                
                % load model parameters
                WijOpt_X   = WijOpt{trainTypeIdx,repIdx,splitIdx};
                
                % run through test groups (=all, subset, cond, subsetCond)
                switch testTypeIdx
                    case 1
                        numGroups = 1;
                    case 2
                        numGroups = max(testSubsetID);
                    case 3
                        numGroups = max(testCondID);
                    case 4
                        numGroups = max(testSubsetCondID);
                end
                
                for grIdx = 1 : numGroups
                    % get data of current test group
                    switch testTypeIdx
                        case 1
                            curTestIdx = 1:size(testData,1);
                        case 2
                            curTestIdx = (find(testSubsetID == grIdx));
                        case 3
                            curTestIdx = (find(testCondID == grIdx));
                        case 4
                            curTestIdx = (find(testSubsetCondID == grIdx));
                    end
                    if length(curTestIdx)>1
                        
                        QicTest = testData(curTestIdx,1);
                        QijTest = testData(curTestIdx,2:end);
                        
                        % get training group definitions of current test data
                        switch trainTypeIdx
                            case 1
                                testXID    = ones(length(curTestIdx),1);
                            case 2
                                testXID    = testSubsetID(curTestIdx);
                            case 3
                                testXID    = testCondID(curTestIdx);
                            case 4
                                testXID    = testSubsetCondID(curTestIdx);
                        end
                        
                        % compute performance measures
                        [curConfusionMatrix,curQicEstA] = testWithTrainingPerX(QicTest,QijTest,testXID,WijOpt_X,funIdx);
                        curQicEst = NaN(size(inData,1),1);
                        curQicEst(testID(curTestIdx)) = curQicEstA;
                        % save performance measures
                        confusionMatrix{testTypeIdx,trainTypeIdx}{funIdx,grIdx,repIdx,splitIdx}  = curConfusionMatrix;
                        QicEst{testTypeIdx,trainTypeIdx}{funIdx,grIdx,repIdx,splitIdx} = curQicEst;
                    else
                        confusionMatrix{testTypeIdx,trainTypeIdx}{funIdx,grIdx,repIdx,splitIdx}  = NaN;
                        QicEst{testTypeIdx,trainTypeIdx}{funIdx,grIdx,repIdx,splitIdx} = NaN;
                    end
                end
            end
        end % end of testing
        
    end % end of repetitions
    % D) compute model performance statistics per test case over repetitions
    for testTypeIdx = testType
        for trainTypeIdx = trainingType
            % run through test groups (=all, subset, cond, subsetCond)
            switch testTypeIdx
                case 1
                    numGroups = 1;
                case 2
                    numGroups = max(testSubsetID);
                case 3
                    numGroups = max(testCondID);
                case 4
                    numGroups = max(testSubsetCondID);
            end
            for grIdx = 1 : numGroups
                
                % compute statistics of confusion matrix over repetitions
                curConfusionMatrix = zeros(2,2,numRep);
                validReps = zeros(numRep,1);
                for repIdx = 1 : numRep
                    curConfusionMatrix(:,:,repIdx) = confusionMatrix{testTypeIdx,trainTypeIdx}{funIdx,grIdx,repIdx,splitIdx};
                    if sum(sum((isnan(curConfusionMatrix(:,:,repIdx))))) == 0
                        validReps(repIdx) = 1;
                    end
                end % end of repetitions
                curConfusionMatrix = curConfusionMatrix(:,:,find(validReps==1));
                curConfusionMatrix_mean = mean(curConfusionMatrix,3);
                curConfusionMatrix_stderr = std(curConfusionMatrix,0,3)/sqrt(numRep);
                df = size(curConfusionMatrix,3)-1; %numRep-1;
                critT = getCritValTdist(df,0.05);
                curConfusionMatrix_ci95 = curConfusionMatrix_stderr*critT;
                % save results
                ConfusionMatrix_mean{   testTypeIdx,trainTypeIdx}{funIdx,grIdx,1,splitIdx} = curConfusionMatrix_mean;
                ConfusionMatrix_stderr{ testTypeIdx,trainTypeIdx}{funIdx,grIdx,1,splitIdx} = curConfusionMatrix_stderr;
                ConfusionMatrix_ci95{   testTypeIdx,trainTypeIdx}{funIdx,grIdx,1,splitIdx} = curConfusionMatrix_ci95;
                
            end
        end
    end
    
end % funIdx
end % splitIdx

% E) save to output

perfStruct.ConfusionMatrix_mean   = ConfusionMatrix_mean;
perfStruct.ConfusionMatrix_stderr = ConfusionMatrix_stderr;
perfStruct.ConfusionMatrix_ci95   = ConfusionMatrix_ci95;

perfStruct.funVec = funVec;
perfStruct.trainTestSplitStats = trainTestSplitStats;

if saveRawFlag
    perfStruct.QicEst = QicEst;
else
    perfStruct.QicEst = 'not saved';
end

perfStruct.WijOpt = WijOpt;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub-functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function WijOpt = trainFx(QicTrain,QijTrain,funIdx)
switch funIdx
    case 1 % SVM model
        WijOpt = fitcsvm(QijTrain,QicTrain);
    case 2 % LDA model
        DiscrimType = 'linear';
        WijOpt = fitcdiscr(QijTrain,QicTrain,'DiscrimType',DiscrimType);
    case 3 % QDA model
        DiscrimType = 'quadratic';
        WijOpt = fitcdiscr(QijTrain,QicTrain,'DiscrimType',DiscrimType);
end

function [confusionMatrix,QicEst] = testWithTrainingPerX(QicTest,QijTest,testXID,WijOpt_X,funIdx)
% run through observations and choose parameters of corresponding subset, 
% then predict that observation
numObs = size(QijTest,1);
QicEst = zeros(numObs,1);
for obsIdx = 1 : numObs
    xIdx = testXID(obsIdx);
    curQijTest = QijTest(obsIdx,:);
    WijOpt = WijOpt_X{funIdx,xIdx};
    switch funIdx
        case 1 % run SMV
            [labelSVM,origScoresSVM] = predict(WijOpt,curQijTest);
            QicEst(obsIdx,1) = labelSVM; % get class
        case 2 % run LDA
            [labelLDA,origScoresLDA] = predict(WijOpt,curQijTest);
            QicEst(obsIdx,1) = labelLDA;
        case 3 % run QDA
            [labelQDA,origScoresQDA] = predict(WijOpt,curQijTest);
            QicEst(obsIdx,1) = labelQDA;
    end
end
% compute confusion matrix
confusionMatrix = zeros(2,2);
for classIdx1 = 1 : 2
    switch classIdx1
        case 1
            class1 = -1;
        case 2
            class1 = 1;
    end
    for classIdx2 = 1 : 2
        switch classIdx2
            case 1
                class2 = -1;
            case 2
                class2 = 1;
        end
        confusionMatrix(classIdx1,classIdx2) = length( find( (QicEst == class2) & (QicTest == class1) ) ) / length( find( (QicTest == class1) ) ) * 100 ;
    end
end


function substIdx = findSubstIDx(validIdx,nonValidIdx)
if isempty(nonValidIdx) && ~isempty(validIdx)
    substIdx = [];
end
if ~isempty(nonValidIdx) && isempty(validIdx)
    substIdx = nonValidIdx;
end
if ~isempty(nonValidIdx) && ~isempty(validIdx)
    substIdx = zeros(1,length(nonValidIdx));
    for xIdx = 1 : length(nonValidIdx)
        candIdx = find(validIdx < nonValidIdx(xIdx)); % get the next smaller valid index
        if ~isempty(candIdx)
            substIdx(xIdx) = validIdx(max(candIdx));
        else
            candIdx = find(validIdx > nonValidIdx(xIdx)); % get the next larger valid index
            if ~isempty(candIdx)
                substIdx(xIdx) = validIdx(min(candIdx));
            else
                substIdx(xIdx) = nonValidIdx(xIdx); % keep index
            end
        end
    end
end
