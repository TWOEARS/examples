function brsPaths = brsFiles()
%brsFiles returns the data base paths of the BRS files

%% === Binaural Room Scanning (BRS) files ===
% Circular array with 56 loudspeakers
nSources = 56;
% Assign BRS files
for n=1:nSources
    sources{n} = sprintf('ls%02.0f.wav', n);
end

%% === Create final data base paths ===
brsPaths = fullfile('experiments/2016-06-01_wfs_mixing_quality/brs', sources');
