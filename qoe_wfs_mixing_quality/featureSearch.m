function [chosenFeatureStruct] = featureSearch(featureData,classLabels)

% Function to run a full (!) search for optimal feature set.
% Attention: this may take veeery long for large feature and data sets.
% For the data of Deliverable D.6.2.3 computation time is fine.

[numObs,numFeats] = size(featureData);
codeTable = calcCodeCombinations(2,15);
codeTable = codeTable(2:end,:);

% codeTable = ones(1,numFeats);

numCombinations = size(codeTable,1);

%numCombinations = 10000;

svmPerf = zeros(numCombinations,1);

tic
for combIdx = 1 : numCombinations
    
    curFeatIdx = find(codeTable(combIdx,:));
    curFeatureData = featureData(:,curFeatIdx);
    
    try
        % fit SVM for the current features
        svmModelFeats = fitcsvm(curFeatureData,classLabels);
    catch
        keyboard
    end
    % predict the corresponding scores of own training data points
    labelSVMownTrain = predict(svmModelFeats,curFeatureData);
    
    % compute performance using class 2, full confusion matrix not needed as
    % performance is symmetric along class 1 and 2
    svmPerf(combIdx) = length( find( (labelSVMownTrain == 1) & (classLabels == 1) ) ) / length( find( (classLabels == 1) ) ) * 100 ;
    
    % confusionMatrixSVM = zeros(2,2);
    % for classIdx1 = 1 : 2
    %     for classIdx2 = 1 : 2
    %         confusionMatrixSVM(classIdx1,classIdx2) = length( find( (labelSVMownTrain == classDataID(classIdx2)) & (classLabels == classDataID(classIdx1)) ) ) / length( find( (classLabels == classDataID(classIdx1)) ) ) * 100 ;
    %     end
    % end
    % confusionMatrixArray{nextPlot-100} = confusionMatrixSVM;
    
end
toc

[amp,pos] = sort(svmPerf);

% figure
% subplot(1,2,1)
% plot(amp,'b+')
% subplot(1,2,2)
% hist(svmPerf,[0:5:100]+2.5)

[maxPerf,chosenCombination1] = max(svmPerf);
pos = find(svmPerf >= 0.95 * maxPerf);
numCandidateFeats = zeros(length(pos),1);
for runIdx = 1 : length(pos)
    numCandidateFeats(runIdx) = length(find(codeTable(pos(runIdx),:)));
end

[amp,posPos] = min(numCandidateFeats);
chosenCombination2 = pos(posPos);
chosenFeatures1 = find(codeTable(chosenCombination1,:))
svmPerf1 = svmPerf(chosenCombination1)
chosenFeatures2 = find(codeTable(chosenCombination2,:))
svmPerf2 = svmPerf(chosenCombination2)

chosenFeatureStruct.chosenFeatures1 = chosenFeatures1;
chosenFeatureStruct.svmPerf1 = svmPerf1;
chosenFeatureStruct.chosenFeatures2 = chosenFeatures2;
chosenFeatureStruct.svmPerf2 = svmPerf2;
numObs
chosenFeatureStruct.numObs = numObs;
