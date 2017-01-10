function [perfStruct] = computeSvmPerfBootstrap(featureData,classLabels,condGroupData,subjGroupData)

% Function to run bootstrap-type model training and validation.

inData = [classLabels featureData]; % the following scripts assume target in first column and features in remaining columns

groupingID = subjGroupData; % consider each data point and its "inverted" data point as one "subject"/group
subsetID = [];

condID = 6*ones(size(condGroupData,1),1); % 6 = mixed condition groups
% overwite with groups
equalCondID = find((condGroupData(:,1)-condGroupData(:,2))==0);
condID(equalCondID) = condGroupData(equalCondID,1);
% deal with zero group comparisons
zeroCondID = find(condGroupData(:,1)==0);
condID(zeroCondID) = condGroupData(zeroCondID,2); % take the other, the non-0 group
zeroCondID = find(condGroupData(:,2)==0);
condID(zeroCondID) = condGroupData(zeroCondID,1); % take the other, the non-0 group
% put zero-only and "ingnored" (-1) comparisons into mixed category
condID(find(condID<=0)) = 6;

proportion = [0.8];
numRep = 100;
funVec = 1;
saveRawFlag = 0;

perfStruct = trainTestModels(inData,groupingID,subsetID,condID,proportion,numRep,funVec,saveRawFlag);

