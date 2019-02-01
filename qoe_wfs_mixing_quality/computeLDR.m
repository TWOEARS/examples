function [ldrFeats,ldrSig,loudnessFast,loudnessSlow,fsOut] = computeLDR (inSig,fsHz)

% Function to compute features based on the LDR feature proposed in 
% Skovenborg, E. (2014), “Measures of Microdynamics.” in 137th Conv. Audio Eng. Soc.

% get signal dimensions, assume time axis in rows, channels in columns
[sigLen,numChannels] = size(inSig);

% compute averaging window lengths for slow and fast loudness measurement
tSlow = 1000; % in ms
tFast = 25; % in ms
winSlow = round(tSlow / 1000 * fsHz); % in samples
winFast = round(tFast / 1000 * fsHz); % in samples

% for "easier" computation, ensure odd window lengths,
% the possible resulting "error" is just one sample
if mod(winSlow,2) > 0
    winSlow = winSlow + 1;
end
if mod(winFast,2) > 0
    winFast = winFast + 1;
end
% get "exact" sampling frequency of output signal, in [Hz]
fsOut = fsHz / (winFast * 1000 );

% compute middle points of windows
%winSlowMidpoint = (winSlow+1)/2;
winFastMidpoint = (winFast+1)/2;

% compute "rounded" half of window length
winSlowHalf = (winSlow-1)/2;
winFastHalf = (winFast-1)/2;

% number of measurement steps
numFastSteps = floor(size(inSig,1) / winFast);
%numSlowSteps = floor(size(inSig,1) / winSlow);

loudnessFast = zeros(numFastSteps,numChannels);
loudnessSlow = zeros(numFastSteps,numChannels); % also this is computed with a time resolution of the fast window
for stepIdx = 1 : numFastSteps
    
    % get currently considered sample
    curMidpointSample = (stepIdx-1)*winFast + winFastMidpoint;
    
    % get boundary samples of fast window
    curLowerSampleFast = curMidpointSample - winFastHalf;
    curUpperSampleFast = curMidpointSample + winFastHalf;
    
    % get current "loudness" for fast window
    loudnessFast(stepIdx,:) = getLoudness(inSig(curLowerSampleFast:curUpperSampleFast,:));
    
    % get boundary samples of slow window
    curLowerSampleSlow = curMidpointSample - winSlowHalf;
    curUpperSampleSlow = curMidpointSample + winSlowHalf;
    
    % pad zeros if necessary for slow window
    curSigExcerpt = inSig( max([curLowerSampleSlow,1]) : min([curUpperSampleSlow,sigLen]) ,:);
    if curLowerSampleSlow <= 0
        numZeros = curLowerSampleSlow+1;
        curSigExcerpt = [zeros(numZeros,numChannels); curSigExcerpt];
    end
    if curUpperSampleSlow > sigLen
        numZeros = curUpperSampleSlow-sigLen;
        curSigExcerpt = [curSigExcerpt; zeros(numZeros,numChannels)];
    end
    
    % get current "loudness" for slow window
    loudnessSlow(stepIdx,:) = getLoudness(curSigExcerpt);
    
end

% compute level
loudnessFast = 10*log10(loudnessFast);
loudnessSlow = 10*log10(loudnessSlow);

% create LDR signal
ldrSig = abs(loudnessFast - loudnessSlow);

% compute LDR as xx% percentile
percentile = 0.95; % if percentile = 100%, then maximum
[amp,pos] = sort(ldrSig,1);
pos95 = round(size(pos,1)*percentile);
LDR = zeros(1,numChannels);
for channelIdx = 1 : numChannels
    LDR(1,channelIdx) = amp(pos95,channelIdx);
end

for chanIdx = 1 : numChannels
    R = corrcoef(loudnessFast(:,chanIdx),loudnessSlow(:,chanIdx));
    Rho(chanIdx) = R(1,2);
end
RMSE = sqrt(mean((loudnessFast-loudnessSlow).^2));
ldrFeats = [LDR; Rho; RMSE];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sub-function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function loudness = getLoudness(inSig)

% currently just rms-value
% may be exchanged with more perceptually motivated loundness computation
loudness = sqrt(mean(inSig.^2));
