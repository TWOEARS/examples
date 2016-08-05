function sim = initBinSim()
%initBinSim initializes the binaural simulator for the Pinte 56 circular loudspeaker array
%
%   USAGE
%       sim = initBinSim()


experimentPath = 'experiments/2016-06-01_wfs_mixing_quality/';
sim = simulator.SimulatorConvexRoom();
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
% vim: set sw=4 ts=4 et tw=90:
