function localise()
% Localisation example comparing localisation with and without head rotations

warning('off','all');
startTwoEars('Config.xml');

% === Configuration
% Different source positions given by BRIRs
% see:
% http://twoears.aipa.tu-berlin.de/doc/latest/database/impulse-responses/#tu-berlin-telefunken-building-room-auditorium-3
brirs = { ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src1_xs+0.00_ys+3.97.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src2_xs+4.30_ys+3.42.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src3_xs+2.20_ys-1.94.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src4_xs+0.00_ys+1.50.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src5_xs-0.75_ys+1.30.sofa'; ...
    'impulse_responses/qu_kemar_rooms/auditorium3/QU_KEMAR_Auditorium3_src6_xs+0.75_ys+1.30.sofa'; ...
    };
robotOrientation = 90; % towards y-axis (facing src1)
sourceAzimuthsWorld = [90, 38.5, -41.4, 90, 120, 60];
sourceAzimuths = sourceAzimuthsWorld - robotOrientation;
nSourceAzimuths = length(sourceAzimuths);

% === Setup binaural simulator
sim = setupBinauralSimulator;

% === Perform localisation
printLocalisationTableHeader();

for ii = 1:nSourceAzimuths

    % Set target azimuth
    targetAzimuth = sourceAzimuths(ii);
    sim.Sources{1}.IRDataset = simulator.DirectionalIR(brirs{ii});

    % Set noise azimuth
    nn = ii + 1; 
    if nn > nSourceAzimuths; nn = nn - nSourceAzimuths; end
    noiseAzimuth = sourceAzimuths(nn);
    sim.Sources{2}.IRDataset = simulator.DirectionalIR(brirs{nn});

    sim.moveRobot(0, 0, robotOrientation);
    sim.rotateHead(0, 'absolute');
    sim.Init = true;
    phiNoTopdown = estimateAzimuth(sim, 'BlackboardDnn.xml');    % DnnLocationKS with top-down mask
    
    sim.moveRobot(0, 0, robotOrientation);
    sim.rotateHead(0, 'absolute');
    sim.ReInit = true;
    phiTopdown = estimateAzimuth(sim, 'BlackboardDnnTopDown.xml');           % DnnLocationKS without top-down mask

    printLocalisationTableColumn(targetAzimuth, ...
                                 noiseAzimuth, ...
                                 phiTopdown, ...
                                 phiNoTopdown);

    % Clean up
    sim.ShutDown = true;

end

printLocalisationTableFooter();

end % of main function

function printLocalisationTableHeader()
    fprintf('\n=== Two-source localisation\n');
    fprintf('----------------------------------------------------------------------------------------\n');
    fprintf('Ref. target azimuth    Ref. noise azimuth    Est. target azimuth    Est. target azimuth\n');
    fprintf('                                             without topdown mask      with topdown mask\n');
    fprintf('----------------------------------------------------------------------------------------\n');
end

function printLocalisationTableColumn(targetAz, noiseAz, phiNoTopdown, phiTopdown)
    fprintf('     %4.0f                  %4.0f                  %4.0f                   %4.0f\n', ...
            wrapTo180(targetAz), wrapTo180(noiseAz), wrapTo180(phiNoTopdown), wrapTo180(phiTopdown));
end

function printLocalisationTableFooter()
    fprintf('----------------------------------------------------------------------------------------\n')
end

% vim: set sw=4 ts=4 expandtab textwidth=90 :
