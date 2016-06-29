function sim = setupBinauralSimulator
%setupBinauralSimulator starts the Binaural SImulator and applies all common
%                       settings, like position of listener and length of
%                       simulation
%
%   USAGE
%       sim = setupBinauralSimulator
%
%   OUTPUT PARAMETERS
%       sim  - Binaural Simulator object

% NOTE: the actual BRS (impulse responses) data set and the audio material
% will be set in the respective functions

% Initialise binaural simulator
sim = simulator.SimulatorConvexRoom();

% Basis parameters - Block size, sample rate and the renderer type
set(sim, ...
	'BlockSize',            4096, ...
    'SampleRate',           44100, ...
    'LengthOfSimulation',   5, ...
    'Renderer',             @ssr_brs, ...
    'Sinks',                simulator.AudioSink(2) ...
    );

% Binaural sensor
set(sim.Sinks, ...
    'Name',                 'Head', ...
    'Position',             [0.00  0.00  0.00]' ...
    );
