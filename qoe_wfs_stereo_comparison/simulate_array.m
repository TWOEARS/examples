startTwoEars('Config.xml');
sim = simulator.SimulatorConvexRoom();

% ===== Simulate WFS =====================================================
% Load audio material, first 10s-30s
inputSignal = audioread(xml.dbGetFile( ...
    'experiments/2015-11-01_wfs_stereo_comparison/stimuli/lighthouse-wfs.wav' ...
    ));
inputSignal = inputSignal(1*441000+1:3*441000,:);
% Setup BinSim for 56 loudspeakers
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
for n=1:nSources
    set(sim.Sources{n}, ...
        'Name', sprintf('Loudspeaker %i', n), ...
        'IRDataset', simulator.DirectionalIR( ...
            ['experiments/2015-11-01_wfs_stereo_comparison/brs/', ...
             sprintf('ls%02.0f.wav', n)]), ...
        'AudioBuffer', simulator.buffer.FIFO(1) ...
        );
    sim.Sources{n}.AudioBuffer.setData(inputSignal(:,n));
end
% Test if simulation is working
sim.set('Init', true);
while ~sim.isFinished()
    sim.set('Refresh', true);  % refresh all objects
    sim.set('Process', true);
end
sim.Sinks.saveFile('binaural_wfs.wav', sim.SampleRate);
sim.set('ShutDown', true);


% ===== Simulate Surround ================================================
% Load audio material, first 10s-30s
inputSignal = audioread(xml.dbGetFile( ...
    'experiments/2015-11-01_wfs_stereo_comparison/stimuli/lighthouse-surround.wav' ...
    ));
channels = [1 2 3 5 6]; % Skip LFE channel
inputSignal = inputSignal(1*441000+1:3*441000,channels);
% Setup BinSim for 5 surround loudspeakers
nSources = 5;
sourceIndices = [52 6 1 40 18]; % Positions of L,R,C,LS,RS loudspeakers
sources = {};
for n=1:nSources
    sources = {sources{:}, simulator.source.Point()};
end
set(sim, ...
    'Renderer', @ssr_brs, ...
    'Sources', sources, ...
    'Sinks', simulator.AudioSink(2) ...
    );
for n=1:nSources
    set(sim.Sources{n}, ...
        'Name', sprintf('Loudspeaker %i', n), ...
        'IRDataset', simulator.DirectionalIR( ...
            ['experiments/2015-11-01_wfs_stereo_comparison/brs/', ...
             sprintf('ls%02.0f.wav', sourceIndices(n))]), ...
        'AudioBuffer', simulator.buffer.FIFO(1) ...
        );
    sim.Sources{n}.AudioBuffer.setData(inputSignal(:,n));
end
% Test if simulation is working
sim.set('Init', true);
while ~sim.isFinished()
    sim.set('Refresh', true);  % refresh all objects
    sim.set('Process', true);
end
sim.Sinks.saveFile('binaural_surround.wav', sim.SampleRate);
sim.set('ShutDown', true);


% ===== Simulate Stereo ==================================================
% Load audio material, first 10s-30s
inputSignal = audioread(xml.dbGetFile( ...
    'experiments/2015-11-01_wfs_stereo_comparison/stimuli/lighthouse-stereo.wav' ...
    ));
inputSignal = inputSignal(1*441000+1:3*441000,:);
% Setup BinSim for 2 stereo loudspeakers
nSources = 2;
sourceIndices = [52 6]; % Positions of L,R,C,LS,RS loudspeakers
sources = {};
for n=1:nSources
    sources = {sources{:}, simulator.source.Point()};
end
set(sim, ...
    'Renderer', @ssr_brs, ...
    'Sources', sources, ...
    'Sinks', simulator.AudioSink(2) ...
    );
for n=1:nSources
    set(sim.Sources{n}, ...
        'Name', sprintf('Loudspeaker %i', n), ...
        'IRDataset', simulator.DirectionalIR( ...
            ['experiments/2015-11-01_wfs_stereo_comparison/brs/', ...
             sprintf('ls%02.0f.wav', sourceIndices(n))]), ...
        'AudioBuffer', simulator.buffer.FIFO(1) ...
        );
    sim.Sources{n}.AudioBuffer.setData(inputSignal(:,n));
end
% Test if simulation is working
sim.set('Init', true);
while ~sim.isFinished()
    sim.set('Refresh', true);  % refresh all objects
    sim.set('Process', true);
end
sim.Sinks.saveFile('binaural_stereo.wav', sim.SampleRate);
sim.set('ShutDown', true);