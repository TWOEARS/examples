function writeBinauralStimuli()
%writeBinauralStimuli writes binaural stimuli of all conditins to stimuli/

startTwoEars('Config.xml');

outDir = 'stimuli';
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

conditions = conditionFiles();
idxTime = [1 1323001]; % / samples (first 30s)

sim = initBinSim();

%% === Assign audio material ===
for ii = 1:length(conditions)
    sim = updateBinSim(sim, ii, idxTime);
    while ~sim.isFinished()
        sim.set('Refresh', true);  % refresh all objects
        sim.set('Process', true);
    end
    [~, name, ext] = fileparts(conditions{ii});
    sim.Sinks.saveFile(fullfile(outDir, strcat(name, ext)), sim.SampleRate);
    sim.Sinks.removeData(); % clear Buffer for next loop
    sim.set('ShutDown', true);
end
% vim: set sw=4 ts=4 et tw=90:
