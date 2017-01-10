% fileProcessor.m

% 0. preparations
% To compute features, set loadFeats to 0. to load features from prepared
% mat-file, set loadFeats to 1.
loadFeats = 1;

% 1. extract/load features

if loadFeats == 0
    % Generate binaural stimuli
    writeBinauralStimuli();
    % load filenames:
    % predefined filename list
    % ! this list takes care of the assignment of condition numbers to filenames: order in fileNames array = condition number
    pathName = 'stimuli/';
    fileNames = { ...
        'wfs_reference.wav', ...
        'stereo.wav', ...
        'wfs_compression_m1.wav', ...
        'wfs_compression_m2.wav', ...
        'wfs_compression_p1.wav', ...
        'wfs_equalizing_m1.wav', ...
        'wfs_equalizing_m2.wav', ...
        'wfs_equalizing_p1.wav', ...
        'wfs_reverb_m1.wav', ...
        'wfs_reverb_m2.wav', ...
        'wfs_reverb_p1.wav', ...
        'wfs_positioning_m1.wav', ...
        'wfs_positioning_m2.wav', ...
        'wfs_positioning_p1.wav', ...
        'wfs_positioning_p2.wav', ...
        'wfs_vocals_compression_equalizing_reverb_m1.wav', ...
        'wfs_vocals_compression_equalizing_reverb_m2.wav', ...
        'wfs_vocals_compression_equalizing_reverb_p1.wav', ...
        'wfs_vocals_compression_equalizing_p1.wav'};
    % note: no data for 'surround.wav', hence this file can be ignored
    numFiles = length(fileNames);

    % go through files and run twoears auditory frontend + own features
    featureData = [];
    for fileIdx = 1 : numFiles

        tic
        disp(['processing file ' num2str(fileIdx) ' of ' num2str(numFiles)])

        % load wav file
        [sIn,fsHz] = audioread([pathName, fileNames{fileIdx}]);

        % extract features
        [curFeatureData, curFList] = extractFeatures (sIn,fsHz);

        % add vanDorpSchuitman features
        [vdsFeatureData, vdsFList] = getVDSfeatures(fileNames{fileIdx});

        % put VDS features inbetween, to have order of feature types
        % consistent with order of comparison groups
        featureData = [featureData; curFeatureData(1:7) vdsFeatureData curFeatureData(8:11)];
        fList = [curFList(1:7) vdsFList curFList(8:11)];
        toc

    end

    disp('done')

    save featureData.mat featureData fList
else
    load featureData.mat
end

% 1.2 compute zscore
featureData = zscore(featureData);

% 2. load perceptual data: pairwise preference ratings
[prefMatArray,condGroupIdArray] = loadPairwisePreferenceData();

% 3. create features and classes per paired comparison
for groupIdx = 1 : length(prefMatArray)
    prefMat = prefMatArray{groupIdx};
    condGroupIDs = condGroupIdArray{groupIdx};
    [featureDataArray{groupIdx},classLabelsArray{groupIdx},classProbArray{groupIdx},condGroupDataArray{groupIdx},subjGroupDataArray{groupIdx}] = generatePairwiseData(prefMat,condGroupIDs,featureData);
end

% 4. compute model performance
for modelType = 1 : 11
% for modelType = [1, 4 : 11] % models 2 and 3 eventually not used for Deliverable D.6.2.3

    for analysisCase = 1 : 4

        switch analysisCase
            case {1,2}
                curFeatureData   = featureDataArray{1};
                curClassLabels   = classLabelsArray{1};
                curClassProb     = classProbArray{1};
                curCondGroupData = condGroupDataArray{1};
                curSubjGroupData = subjGroupDataArray{1};
            case {3,4}
                curFeatureData   = [featureDataArray{2};   featureDataArray{3};   featureDataArray{4};   featureDataArray{5};   featureDataArray{6}  ];
                curClassLabels   = [classLabelsArray{2};   classLabelsArray{3};   classLabelsArray{4};   classLabelsArray{5};   classLabelsArray{6}  ];
                curClassProb     = [classProbArray{2};     classProbArray{3};     classProbArray{4};     classProbArray{5};     classProbArray{6}    ];
                curCondGroupData = [condGroupDataArray{2}; condGroupDataArray{3}; condGroupDataArray{4}; condGroupDataArray{5}; condGroupDataArray{6}];
                curSubjGroupData = [subjGroupDataArray{2}; subjGroupDataArray{3}; subjGroupDataArray{4}; subjGroupDataArray{5}; subjGroupDataArray{6}];
        end
        switch analysisCase
            case {1,3}
                probCrit = -0.1;
            case {2,4}
                probCrit = 0.1;
        end
        switch analysisCase
            case 1
                disp('Analysis Case 1: all data')
            case 2
                disp('Analysis Case 2: all conditions, with clear preference only')
            case 3
                disp('Analysis Case 3: "per-group conditions", with all preference values')
            case 4
                disp('Analysis Case 4: "per-group conditions", with clear preference only')
        end
        strongDataId = find(abs(curClassProb(:,2)-0.5)>probCrit);
        curFeatureData   = curFeatureData(strongDataId,:);
        curClassLabels   = curClassLabels(strongDataId);
        curClassProb     = curClassProb(strongDataId,:);
        curCondGroupData = curCondGroupData(strongDataId,:);
        curSubjGroupData = curSubjGroupData(strongDataId,:);

        switch modelType
            case 1
                % model 1: full model
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData,curClassLabels,curCondGroupData,curSubjGroupData);
            case 2
                % model 2: maxPerf for analysisCase 1
                % obtained with %[chosenFeatureStruct] = featureSearch(curFeatureData,curClassLabels);
				% eventually not used in experiments for deliverable D.6.2.3
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[1 2 3 4 6 7 9 10 11 12 13 14 15]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 3
                % model 3: 95% of maxPerf for analysisCase 1
                % obtained with %[chosenFeatureStruct] = featureSearch(curFeatureData,curClassLabels);
				% eventually not used in experiments for deliverable D.6.2.3
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[4 7 9 11 12 14 15]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 4
                % model 4: LDR features only - for group 1 compression
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[1:3]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 5
                % model 5: spectral features only - for group 2 eq
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[4:7]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 6
                % model 6: VDS features only - for group 3 - reverb
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[12:15]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 7
                % model 7: localization features only - for group 4 - positioning
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[8:11]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 8
                % model 8: all except LDR features
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[4:15]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 9
                % model 9: all except spectral features
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[1:3,8:15]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 10
                % model 10: all except VDS features
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[1:11]),curClassLabels,curCondGroupData,curSubjGroupData);
            case 11
                % model 11: all except localization features
                [perfStruct] = computeSvmPerfBootstrap(curFeatureData(:,[1:7,12:15]),curClassLabels,curCondGroupData,curSubjGroupData);
        end
        eval(['save perfStructArray_' num2str(modelType) '_' num2str(analysisCase) '.mat perfStruct'])
    end

end

% 5. plot model performance
plotModelPerformance
