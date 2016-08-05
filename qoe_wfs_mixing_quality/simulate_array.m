
%% === References ===
%
% [1] C. Hold, H. Wierstorf, A. Raake, "The Difference between Stereophony and
%     Wave Field Synthesis in the Context of Popular Music", in 140th AES
%     Convention, paper 9533, 2016. http://www.aes.org/e-lib/browse.cfm?elib=18232

startTwoEars('Config.xml');
sim = simulator.SimulatorConvexRoom();


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


%% === Binaural simulation of loudspeaker array ===
% Initialize 56 loudspeakers
nSources = 56;
sources = {};
for n=1:nSources
    sources = {sources{:}, simulator.source.Point()};
end
set(sim, ...
    'Renderer', @ssr_brs, ...
    'Sources', sources, ...
    'Sinks', simulator.AudioSink(2) ...
    );
% Assign BRS files
for n=1:nSources
    set(sim.Sources{n}, ...
        'Name', sprintf('Loudspeaker %i', n), ...
        'IRDataset', simulator.DirectionalIR( ...
            [experimentPath, 'brs/', sprintf('ls%02.0f.wav', n)]), ...
        'AudioBuffer', simulator.buffer.FIFO(1) ...
        );
end


%% === Assign audio material ===
% The following is an example how to create the stimuli for the compression part
idxConditions = 1:5; % setreo, wfs, compression
for ii = 1:length(idxConditions)
    inputSignal = audioread(xml.dbGetFile([experimentPath, conditions{idxConditions(ii)}]));
    % Use only first 10s-30s
    inputSignal = inputSignal(1*441000+1:3*441000,:);
    % Assign audio signal to binaural simulation
    for n=1:nSources
        sim.Sources{n}.AudioBuffer.setData(inputSignal(:,n));
    end
    % Write audio signal
    sim.set('Init', true);
    while ~sim.isFinished()
        sim.set('Refresh', true);  % refresh all objects
        sim.set('Process', true);
    end
    sim.Sinks.saveFile(sprintf('condition_%i.wav', idxConditions(ii)), sim.SampleRate);
    sim.set('ShutDown', true);
end
% vim: set sw=4 ts=4 et tw=90:
