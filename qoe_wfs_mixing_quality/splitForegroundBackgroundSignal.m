function [sigForeground, sigBackground, idxForground, idxBackground] = splitForegroundBackgroundSignal(sig, fs);
%splitForegroundBackgroundSignal returns a forground and background signal
%stream
%
%   USAGE
%       [sigForeground, sigBackground, idxForground, idxBackground] = ...
%           splitForegroundBackgroundSignal(sig, fs);
%
%   INPUT PARAMETERS
%       sig         - signal to be splitted, this should be a low passed
%                     filtered signal processed by the adaptation processor of
%                     the Two!Ears Auditory Front-End
%       fs          - Sampling arte / Hz
%
%   OUTPUT PARAMETERS
%       sigForeground   - forground signal
%       sigBackground   - background signal
%       idxForground    - index of signal parts belonging to foreground
%       idxBackground   - index of signal parts belonging to background
%
%   DETAILS
%       The splitting into forground and background is implememted after van
%       Dorp Schuitman et al., "Deriving content-specific measures of room
%       acoustic perception using a binaural, nonlinear auditory model," JASA
%       133, p. 1572-1585, 2013.

% Original parameter of the model (Table II in the paper)
%MU = 7.49*10^-3;
%MUdip = -1.33*10^-3;
%Tmin = 63.1*1000/fs;

% Adjusted parameter
MU = 1;
MUdip = -0.5;
Tmin = 63.1*1000/fs;

% Positive and negative splitting thresholds
Ymin = MU * mean(abs(sig));
Ymindip = MUdip * mean(abs(sig));

sigForeground = sig;
sigBackground = sig;

% === Positive signal part ===
% Find signal parts above the positive threshold
idx = find(sig>Ymin);
% Find parts above the threshold for a period of Tmin
idxForgroundPositive = thresholdForSomeTime(idx, Tmin);

% === Negative signal part ===
% Find signal parts below the negative threshold
idx = find(sig<Ymindip);
% Find parts below the threshold for a period of Tmin
idxForgroundNegative = thresholdForSomeTime(idx, Tmin);

% === Combine parts ===
idxForground = union(idxForgroundPositive, idxForgroundNegative);
idxBackground = setdiff(1:length(sig), idxForground);
sigForeground(idxBackground) = 0;
sigBackground(idxForground) = 0;

function idx = thresholdForSomeTime(idx, N);
    a = diff(idx');
    idx_end = find([a inf]>1); % end points
    idx_start = [1 idx_end(1:end-1)+1]; % start points
    c = diff([0 idx_end]); % length of parts
    % Remove all idx entries below a length of N
    idx_min = c>N;
    idx_end = idx_end(idx_min);
    idx_start = idx_start(idx_min);
    idx_new = [];
    for ii=1:length(idx_end)
        idx_new = [idx_new idx_start(ii):idx_end(ii)];
    end
    idx = idx(idx_new);
end
end
% vim: set sw=4 ts=4 et tw=90:
