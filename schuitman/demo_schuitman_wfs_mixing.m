startTwoEars('segmentation_config.xml');

idxTime = [10,13]*44100; % 2 seconds

sim = initBinSim();
conditions = conditionFiles();

idxConditions = [3 14 15]; % [m2 m1 ref p1 p2]
reverb = {};
clarity = {};
asw = {};
lev = {};
azimuth = {};
segmentation = {};
for ii=1:length(idxConditions)
    idx = idxConditions(ii);
    sim = updateBinSim(sim, idx, idxTime);
    bbs = BlackboardSystem(0);
    bbs.setRobotConnect(sim);
    bbs.buildFromXml('schuitman_blackboard_wfs_mixing.xml');
    bbs.run();
    
    %
    reverb{ii} = bbs.blackboard.getData('ReverberanceHypotheses');
    clarity{ii} = bbs.blackboard.getData('ClarityHypotheses');
    asw{ii} = bbs.blackboard.getData('ASWHypotheses');
    lev{ii} = bbs.blackboard.getData('LEVHypotheses');
    azimuth{ii} = bbs.blackboard.getData('sourceAzimuthHypotheses');
    segmentation{ii} = bbs.blackboard.getData('segmentationHypotheses');
end

% vim: set sw=4 ts=4 et tw=90: