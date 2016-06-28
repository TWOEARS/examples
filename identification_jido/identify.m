function bbs = identify(pathToGenomix, idModels)
%IDENTIFY identifies sources positioned at 0 deg and returns the blackboard object

if nargin < 2, idModels = setDefaultIdModels(); end

%warning('off', 'all');
disp( 'Initializing Two!Ears, setting up interface to robot...' );
startTwoEars('Config.xml');

% create fake labels and on/offsets
labels = 'baby';
onOffsets = [-0.2908   -1.2418];

% === Initialize Interface to Jido
jido = JidoInterface(pathToGenomix);

% === Initialise and run model
disp( 'Building blackboard system...' );
bbs = buildIdentificationBBS(jido, idModels, labels, onOffsets);
disp( 'Starting blackboard system.' );
bbs.run();

% === Evaluate scores
%idScoresRelativeError(bbs,labels,onOffsets);

% finish

% vim: set sw=4 ts=4 expandtab textwidth=90 :
