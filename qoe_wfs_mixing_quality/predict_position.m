startTwoEars('Config.xml');

sim = initBinSim();

idxConditions = [9 10 11 12]; % [m2 m1 p1 p2]
for ii=1:length(idxConditions)
    idx = idxConditions(ii);
    sim = updateBinSim(sim, idx);
    bbs = BlackboardSystem(0);
    bbs.setRobotConnect(sim);
    bbs.buildFromXml('Blackboard.xml');
    bbs.run();
    phiDistribution = bbs.blackboard.getData('sourcesAzimuthsDistributionHypotheses');
    % Average over time
    dist = zeros(1,37);
    for jj=1:size(phiDistribution, 2)
        dist = dist + phiDistribution(jj).data.sourcesDistribution;
    end
    distribution{ii} = dist / size(phiDistribution, 2);
    figure;
    plot(phiDistribution(1).data.azimuths, distribution{ii});
    title(sprintf('Condition %i', idx));
    xlabel('Azimuth / deg');
    ylabel('Probability');
end

% Analysis

% vim: set sw=4 ts=4 et tw=90:
