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

startTwoEars('schuitman_config.xml');

brirs = { ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src1_xs+0.00_ys+3.97.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src2_xs+4.30_ys+3.42.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src3_xs+2.20_ys-1.94.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src4_xs+0.00_ys+1.50.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src5_xs-0.75_ys+1.30.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src6_xs+0.75_ys+1.30.sofa'; ...
    'impulse_responses/qu_kemar_rooms/spirit/QU_KEMAR_spirit_src1_30deg.sofa'; ...
    'impulse_responses/qu_kemar_rooms/spirit/QU_KEMAR_spirit_src2_0deg.sofa'; ...
    'impulse_responses/qu_kemar_rooms/spirit/QU_KEMAR_spirit_src3_-30deg.sofa'; ...
    };

%
sim = simulator.SimulatorConvexRoom;  
% Suppress simulator messages
set(sim, 'Verbose', false);
%
sim.loadConfig('test_scene_auditorium.xml');
% set look direction 
sim.rotateHead(90, 'absolute');

reverb = [];
clarity = [];
asw = [];
lev = [];
for idx=1:length(brirs)
  %
  sim.Sources{1}.IRDataset = simulator.DirectionalIR(brirs{idx});
  %
  sim.Sources{1}.AudioBuffer.loadFile(db.getFile('sound_databases/grid_subset/s1/bbaf2n.wav'), 44100);
  % Initialize simulation
  set(sim, 'Init', true);
  % Initialize Blackboard System
  bbs = BlackboardSystem(false);
  bbs.setRobotConnect(sim);
  bbs.buildFromXml('schuitman_blackboard_auditorium.xml');
  % Start Blackboard System and run simulation
  bbs.run();
  %
  reverb = [reverb, bbs.blackboard.getData('ReverberanceHypotheses')];
  clarity = [clarity, bbs.blackboard.getData('ClarityHypotheses')];
  asw = [asw, bbs.blackboard.getData('ASWHypotheses')];
  lev = [lev, bbs.blackboard.getData('LEVHypotheses')];
  % Shut down simulation
  set(sim, 'ShutDown', true);
end
