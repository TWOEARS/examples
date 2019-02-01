function [featureData, fList] = extractFeatures(sIn,fsHz)

% init output
featureData = [];
fList = {};

% A) run Two!Ears Auditory Front-End

% Instantiation of data and manager objects
dataObj        = dataObject(sIn,fsHz);
managerObj     = manager(dataObj);

% Request the computation of spectral features
sOutSpecFeats  = managerObj.addProcessor('spectralFeatures');

% Request the computation of gammatone filterbank
sOutGammatone  = managerObj.addProcessor('filterbank');

% Request the computation of ILD
sOutILD        = managerObj.addProcessor('ild');

% Request the computation of ITD
sOutITD        = managerObj.addProcessor('itd');

% Request the processing
managerObj.processSignal;

disp('  Auditory Front-End ready')

% B) compute "own" features

% B.1 compute LDR features, potentially describing compression

curInSig       = sOutGammatone{1}.Data(:);
curFsHz        = sOutGammatone{1}.FsHz;
fInHz          = sOutGammatone{1}.cfHz;
ldrFeatsLeft   = computeLDR(curInSig,curFsHz);               % 3Features x 31Filters

curInSig       = sOutGammatone{2}.Data(:);
curFsHz        = sOutGammatone{2}.FsHz;
fInHz          = sOutGammatone{2}.cfHz;
ldrFeatsRight  = computeLDR(curInSig,curFsHz);               % 3Features x 31Filters

% process features over gammatone filters
% note: frequency weighting of channels is done already in computeLDR.m
ldrFeatsLeft   = mean(ldrFeatsLeft,2);                       % 3Features x 1
ldrFeatsRight  = mean(ldrFeatsRight,2);                      % 3Features x 1

% process features over channels
ldrFeats       = mean([ldrFeatsLeft, ldrFeatsRight],2);      % 3Features x 1

% correct dimension
ldrFeats       = ldrFeats'; % 1 x 3Features

% add to output
featureData    = [featureData ldrFeats];

% add feature names
fList          = [fList {'LDR_Diff','LDR_Rho','LDR_RMSE'}];

disp('  Compression features ready')


% B.2 compute spectral features, potentially describing equalization

specFeatsLeft  = sOutSpecFeats{1}.Data(:);                   % nSamples x 14Features
specFeatsRight = sOutSpecFeats{2}.Data(:);                   % nSamples x 14Features

% process features over time
specFeatsLeft  = mean(specFeatsLeft ,1);                     % 1 x 14Features
specFeatsRight = mean(specFeatsRight,1);                     % 1 x 14Features

% process fatures over channels
specFeats      = mean([specFeatsLeft; specFeatsRight],1);    % 1 x 14Features

% select the presumably best four of the six features from Nagel2016
featSelection  = [7 14 4 12];
specFeats      = specFeats(featSelection);                   % 1 x 6Features

% add to output
featureData    = [featureData specFeats];

% add feature names
fList          = [fList sOutSpecFeats{1}.fList(featSelection)];

disp('  Spectral features ready')



% B.3 compute localisation features
itdFeats       = sOutITD{1}.Data(:);                        % nSamples x 31Filters
ildFeats       = sOutILD{1}.Data(:);                        % nSamples x 31Filters

% process features over time
itdFeats       = std(itdFeats,[],1);                        % 1 x 31Filters
ildFeats       = std(ildFeats,[],1);                        % 1 x 31Filters

% process features over filters
itdFeats       = [mean(itdFeats,2), std(itdFeats,[],2)];    % 1 x 2Features
ildFeats       = [mean(ildFeats,2), std(ildFeats,[],2)];    % 1 x 2Features

% add to output
featureData    = [featureData itdFeats ildFeats];

% add feature names
fList          = [fList {'ITD_stdTime_meanFilters' 'ITD_stdTime_stdFilters' 'ILD_stdTime_meanFilters' 'ILD_stdTime_stdFilters'}];

disp('  Localization features ready')



