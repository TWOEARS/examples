function sim = updateBinSim(sim, idxCondition)
%updateBinSim switch to another audio condition
%
%   USAGE
%       sim = updateBinSim(sim, idxCondition)
%
%   INPUT PARAMETERS
%       sim          - binaural simulator object
%       idxCondition - idx number of condition. This can be:
%                       1 : stereo
%                       2 : wfs_reference
%                       3 : wfs_compression_m2
%                       4 : wfs_compression_m1
%                       5 : wfs_compression_p1
%                       6 : wfs_equalizing_m2
%                       7 : wfs_equalizing_m1
%                       8 : wfs_equalizing_p1
%                       9 : wfs_positioning_m2
%                      10 : wfs_positioning_m1
%                      11 : wfs_positioning_p1
%                      12 : wfs_positioning_p2
%                      13 : wfs_reverb_m2
%                      14 : wfs_reverb_m1
%                      15 : wfs_reverb_p1
%                      16 : wfs_vocals_compression_equalizing_reverb_m2
%                      17 : wfs_vocals_compression_equalizing_reverb_m1
%                      18 : wfs_vocals_compression_equalizing_reverb_p1
%                      19 : wfs_vocals_compression_equalizing_p1
%
%   OUTPUT PARAMETERS
%       sim         - updated binaural simulator object

%% === References ===
%
% [1] C. Hold, H. Wierstorf, A. Raake, "The Difference between Stereophony and
%     Wave Field Synthesis in the Context of Popular Music", in 140th AES
%     Convention, paper 9533, 2016. http://www.aes.org/e-lib/browse.cfm?elib=18232


nargchk(2,2,nargin);

%% === Conditions ===
% The experiment was a paired comparison test, where one music piece was mixed
% for WFS and the mix changed at different dimensions afterwards.
experimentPath = 'experiments/2016-06-01_wfs_mixing_quality/';
conditions = { ...
    'stimuli/stereo.wav';               % stereo condition from QoE 010 [1]
    'stimuli/wfs_reference.wav';        % WFS condition from QoE 010 [1]
    'stimuli/wfs_compression_m2.wav';   % compression switched off
    'stimuli/wfs_compression_m1.wav';   % less compression
    'stimuli/wfs_compression_p1.wav';   % more compression
    'stimuli/wfs_equalizing_m2.wav';    % equalizer switched off
    'stimuli/wfs_equalizing_m1.wav';    % less EQing
    'stimuli/wfs_equalizing_p1.wav';    % more EQing
    'stimuli/wfs_positioning_m2.wav';   % very narrow foreground
    'stimuli/wfs_positioning_m1.wav';   % narrow foreground
    'stimuli/wfs_positioning_p1.wav';   % wider foreground + vocal to the right
    'stimuli/wfs_positioning_p2.wav';   % very wide foreground + vocal more to the right
    'stimuli/wfs_reverb_m2.wav';        % reverb switched off
    'stimuli/wfs_reverb_m1.wav';        % less reverb
    'stimuli/wfs_reverb_p1.wav';        % more reverb
    'stimuli/wfs_vocals_compression_equalizing_reverb_m2.wav'; % compression, EQ, and reverb switched off on vocals
    'stimuli/wfs_vocals_compression_equalizing_reverb_m1.wav'; % less compression, EQ, and reverb on vocals
    'stimuli/wfs_vocals_compression_equalizing_reverb_p1.wav'; % more compression, EQ, and reverb on vocals
    'stimuli/wfs_vocals_compression_equalizing_p1.wav';        % more compression, and EQ on vocals
    };
nSources = 56;


%% === Assign audio material ===
sim.set('ShutDown', true);
inputSignal = audioread(xml.dbGetFile([experimentPath, conditions{idxCondition}]));
% Use only first 10s-20s
inputSignal = inputSignal(1*441000+1:2*441000,:);
% Assign audio signal to binaural simulation
if idxCondition==1 % stereo uses only two loudspeakers
    sim.Sources{52}.AudioBuffer.setData(inputSignal(:,57));
    sim.Sources{6}.AudioBuffer.setData(inputSignal(:,58));
else
    for n=1:nSources
        sim.Sources{n}.AudioBuffer.setData(inputSignal(:,n));
    end
end
% Write audio signal
sim.set('Init', true);
% vim: set sw=4 ts=4 et tw=90:
