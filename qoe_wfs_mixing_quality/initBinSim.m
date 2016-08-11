function sim = initBinSim()
%initBinSim initializes the binaural simulator for the Pinta 56 circular loudspeaker array
%
%   USAGE
%       sim = initBinSim()

sim = simulator.SimulatorConvexRoom();
brsPaths = brsFiles();
nSources = length(brsPaths);
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
        'IRDataset', simulator.DirectionalIR(brsPaths{n}), ...
        'AudioBuffer', simulator.buffer.FIFO(1) ...
        );
end
% vim: set sw=4 ts=4 et tw=90:
