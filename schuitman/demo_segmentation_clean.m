%% Demo 1: Segmentation of an acoustic mixture without background noise
%
% This script demonstrates the usage of the Segmentation Knowledge Source
% with the blackboard system for a mixture of 3 sound sources without
% additional background noise in anechoic conditions. The acoustic scene 
% contains three speakers at 30°, 0° and -30°.
%
% AUTHOR:
%   Christopher Schymura (christopher.schymura@rub.de)
%   Cognitive Signal Processing Group
%   Ruhr-Universitaet Bochum
%   Universitaetsstr. 150, 44801 Bochum

startTwoEars('segmentation_config.xml');

% Initialize Binaural Simulator
sim = simulator.SimulatorConvexRoom('test_scene_clean.xml');

% Suppress simulator messages
set(sim, 'Verbose', false);

% Set look direction to zero degrees
sim.rotateHead(0, 'absolute');

% Initialize simulation
set(sim, 'Init', true);

% Initialize Blackboard System
bbs = BlackboardSystem(false);
bbs.setRobotConnect(sim);
bbs.buildFromXml('segmentation_blackboard_clean.xml');

% Start Blackboard System and run simulation
bbs.run();

% Shut down simulation
set(sim, 'ShutDown', true);

