function sim = setupBinauralSimulator()
%setupBinauralSimulator starts the Binaural SImulator and applies all common
%                       settings, like position of listener and length of
%                       simulation
%
%   USAGE
%       sim = setupBinauralSimulator()
%
%   OUTPUT PARAMETERS
%       sim  - Binaural Simulator object

% NOTE: the actual BRS (impulse responses) data set and the audio material
% will be set in the respective functions

sim = simulator.SimulatorConvexRoom();

% Setup a two-source simulation
set(sim, ...
    'BlockSize',            4096, ...
    'SampleRate',           44100, ...
    'NumberOfThreads',      1, ...
    'LengthOfSimulation',   1, ...
    'Renderer',             @ssr_brs, ...
    'Verbose',              false, ...
    'Sources',              {simulator.source.Point(), simulator.source.Point()}, ...
    'Sinks',                simulator.AudioSink(2) ...
    );

% Binaural sensor
set(sim.Sinks, ...
    'Name',                 'Head', ...
    'Position',             [0.00  0.00  0.00]' ...
    );

% Set the target source
set(sim.Sources{1}, ...
    'AudioBuffer',          simulator.buffer.Ring(1) ...
    );
sim.Sources{1}.AudioBuffer.loadFile( ...
  'sound_databases/grid_subset/s2/bbas2a.wav', sim.SampleRate);

% Set the noise source
set(sim.Sources{2}, ...
    'AudioBuffer',          simulator.buffer.Ring(1) ...
    );
sim.Sources{2}.AudioBuffer.loadFile( ...
  'noise/alarm.wav', sim.SampleRate);

% vim: set sw=4 ts=4 et tw=90: