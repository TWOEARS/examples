function conditionPaths = conditionFiles()
%conditionFiles returns the pathes of the condition files in the data base


%% === Conditions ===
% The experiment was a paired comparison test, where one music piece was mixed
% for WFS and the mix changed at different dimensions afterwards.
conditions = { ...
    'stereo.wav';               % stereo condition from QoE 010 [1]
    'wfs_reference.wav';        % WFS condition from QoE 010 [1]
    'wfs_compression_m2.wav';   % compression switched off
    'wfs_compression_m1.wav';   % less compression
    'wfs_compression_p1.wav';   % more compression
    'wfs_equalizing_m2.wav';    % equalizer switched off
    'wfs_equalizing_m1.wav';    % less EQing
    'wfs_equalizing_p1.wav';    % more EQing
    'wfs_positioning_m2.wav';   % very narrow foreground
    'wfs_positioning_m1.wav';   % narrow foreground
    'wfs_positioning_p1.wav';   % wider foreground + vocal to the right
    'wfs_positioning_p2.wav';   % very wide foreground + vocal more to the right
    'wfs_reverb_m2.wav';        % reverb switched off
    'wfs_reverb_m1.wav';        % less reverb
    'wfs_reverb_p1.wav';        % more reverb
    'wfs_vocals_compression_equalizing_reverb_m2.wav'; % compression, EQ, and reverb switched off on vocals
    'wfs_vocals_compression_equalizing_reverb_m1.wav'; % less compression, EQ, and reverb on vocals
    'wfs_vocals_compression_equalizing_reverb_p1.wav'; % more compression, EQ, and reverb on vocals
    'wfs_vocals_compression_equalizing_p1.wav';        % more compression, and EQ on vocals
    };
%
% [1] C. Hold, H. Wierstorf, A. Raake, "The Difference between Stereophony and
%     Wave Field Synthesis in the Context of Popular Music", in 140th AES
%     Convention, paper 9533, 2016. http://www.aes.org/e-lib/browse.cfm?elib=18232


%% === Create final data base paths ===
conditionPaths = fullfile('experiments/2016-06-01_wfs_mixing_quality/stimuli', ...
                          conditions);

% vim: set sw=4 ts=4 et tw=90:
