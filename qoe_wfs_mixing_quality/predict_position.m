startTwoEars('Config.xml');

idxTime = [1:5*44100]; % 0-30s

sim = initBinSim();
conditions = conditionFiles();

idxConditions = [9 10 2 11 12]; % [m2 m1 ref p1 p2]
for ii=1:length(idxConditions)
    idx = idxConditions(ii);
    sim = updateBinSim(sim, idx);
    bbs = BlackboardSystem(0);
    bbs.setRobotConnect(sim);
    bbs.buildFromXml('Blackboard.xml');
    bbs.run();
    phiDistributions{ii} = bbs.blackboard.getData('sourcesAzimuthsDistributionHypotheses');
end

return

% Analysis and plotting
for ii=1:length(idxConditions)
    idx = idxConditions(ii);
    phiDistribution = phiDistributions{ii};
    % Average over time
    dist = zeros(1,37);
    for jj=1:size(phiDistribution, 2)
        dist = dist + phiDistribution(jj).data.sourcesDistribution;
    end
    distribution{ii} = dist / size(phiDistribution, 2);
    figure;
    plot(wrapTo180(phiDistribution(1).data.azimuths), distribution{ii});
    [~, name] = fileparts(conditions{idx});
    title(sprintf('Condition %i %s', idx, name));
    xlabel('Azimuth / deg');
    ylabel('Probability');
end

% Analysis

% vim: set sw=4 ts=4 et tw=90:
