% === Parameters of the simulation

% --- Take all audiovisual pairs
htm_path = '../../audio-visual-integration/head_turning_modulation_model_simdata';

addpath(genpath(htm_path));

% --- In the Init folder is an 'AVPairs.xml' file containing the audiovisual objects used for the simulation.
% --- These pairs consist more on a comprehensive A-to-B pairing than a true audio+visual pairings.
% --- Indeed, they will be used to create dedicated classifiers whose output will be simulated.
% --- The 'scene' variable is used to define the AV pairs you'd like to use for the simulation
% --- 'scene = 0' means that every AV pairs listed in the 'AVPairs.xml' file will be used. This is the default value.
% --- 'scene = [1, 3, 5:10, 30]' means that only AV pairs n�1, 3, 5 to 10, and 30 will be used.
% --- This variable is OPTIONAL.
% scene = [1:5:20];

% --- By default, instanciating the HeadTurningModulationKS will make the simulation run.
% --- Set 'run_sim' to 'false' if you don't want the simulation to begin.
% --- This variable is OPTIONAL.
% run_sim = true;

% --- The variable 'steps' is the number of discrete time steps of the simulation.
% --- By default, 'steps' is set to 0 which launch a 1000 steps simulation.
% --- This variable is OPTIONAL.
% steps = 200;

htm = HeadTurningModulationKS();

% --- The simulation can take some time (depending on the complexity of the scenario simulated).
% --- Don't bother checking regularly if the simulation is over: a notification is played once it is ;)

RIR = htm.RIR;
MOKS = htm.MotorOrderKS;
MFI = htm.MFI;
MSOM = htm.MSOM;
ENV = RIR.getEnv();
ODKS = htm.ODKS;

% --- Once the simulation is over, statistics on the HTM performances are computed.
% --- 'plotGoodClassif': will plot the average good classification over time versus a naive fusion algorithm (to be changed soon)
% --- 'plotGoodClasssifObj': same as above but with the possibility to focus on given objects
% --- 'plotSHM': will plot the number of head movements triggered by the HTM versus a naive robot
% --- 'plotHits': will plot the state of the MSOM at the end of the simulation. Helps observe the tonotopy of the network.

% plotGoodClassif(htm, 'Max', false);
