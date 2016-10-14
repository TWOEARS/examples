function segregate()
% Auditory stream-segregation example

warning('off', 'all');
startTwoEars('Config.xml');

% Initialize binaural simulator
sim = setupBinauralSimulator();

bbs = BlackboardSystem(0);
bbs.setRobotConnect(sim);
bbs.buildFromXml('SegmentationKSExample.xml');

bbs.run();
% % Evaluate localization results
predictedAzimuths = bbs.blackboard.getData('sourcesAzimuthsDistributionHypotheses');
% phi = evaluateLocalisationResults(predictedAzimuths);
1