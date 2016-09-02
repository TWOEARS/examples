function sim = updateBinSim(sim, idxCondition, idxTime)
%updateBinSim switch to another audio condition
%
%   USAGE
%       sim = updateBinSim(sim, idxCondition, [idxTime])
%
%   INPUT PARAMETERS
%       sim          - binaural simulator object
%       idxCondition - idx number of condition. This can be:
%                       1 : stereo
%                       2 : surround
%                       3 : wfs_reference
%                       4 : wfs_compression_m2
%                       5 : wfs_compression_m1
%                       6 : wfs_compression_p1
%                       7 : wfs_equalizing_m2
%                       8 : wfs_equalizing_m1
%                       9 : wfs_equalizing_p1
%                      10 : wfs_positioning_m2
%                      11 : wfs_positioning_m1
%                      12 : wfs_positioning_p1
%                      13 : wfs_positioning_p2
%                      14 : wfs_reverb_m2
%                      15 : wfs_reverb_m1
%                      16 : wfs_reverb_p1
%                      17 : wfs_vocals_compression_equalizing_reverb_m2
%                      18 : wfs_vocals_compression_equalizing_reverb_m1
%                      19 : wfs_vocals_compression_equalizing_reverb_p1
%                      20 : wfs_vocals_compression_equalizing_p1
%       idxTime      - [timeStart timeStop] in samples,
%                      default: [441001 882000] => 10s - 20s
%
%   OUTPUT PARAMETERS
%       sim         - updated binaural simulator object

%% === References ===
%
% [1] C. Hold, H. Wierstorf, A. Raake, "The Difference between Stereophony and
%     Wave Field Synthesis in the Context of Popular Music", in 140th AES
%     Convention, paper 9533, 2016. http://www.aes.org/e-lib/browse.cfm?elib=18232


nargchk(2,3,nargin);
if nargin<3
    idxTime = [441001 882000];
end

%% === Conditions ===
conditions = conditionFiles();
nSources = 56;


%% === Assign audio material ===
sim.set('ShutDown', true);
inputSignal = audioread(xml.dbGetFile(conditions{idxCondition}));
% Use only first 10s-20s
inputSignal = inputSignal(idxTime(1):idxTime(2), :);
% Assign audio signal to binaural simulation
if idxCondition==1 % stereo uses only two loudspeakers
    sim.Sources{52}.AudioBuffer.setData(inputSignal(:, 1));
    sim.Sources{6}.AudioBuffer.setData(inputSignal(:, 2));
elseif idxCondition == 2 % surround
    sim.Sources{1}.AudioBuffer.setData(inputSignal(:,3));
    sim.Sources{52}.AudioBuffer.setData(inputSignal(:,1));
    sim.Sources{6}.AudioBuffer.setData(inputSignal(:,2));
    sim.Sources{40}.AudioBuffer.setData(inputSignal(:,5));
    sim.Sources{18}.AudioBuffer.setData(inputSignal(:,6));
else
    for n=1:nSources
        % Flip channel as the WFS conditions are stored in the wrong order!
        sim.Sources{n}.AudioBuffer.setData(inputSignal(:, 57-n));
    end
end
% Write audio signal
sim.set('Init', true);
% vim: set sw=4 ts=4 et tw=90:
