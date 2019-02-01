function [featureData, fList] = getVDSfeatures(fileName)

% construct dummy vDS model output from https://dev.qu.tu-berlin.de/projects/twoears/wiki/QoE_call_2016-09

featureData = [];
fList       = {'sRev','sClar','sASW','sLEV'};


switch fileName
    
    case 'stereo.wav'
        % deal with values for stereo condition, which are slightly different for each group
        xSte(1,:) = [0.999892 , 0.07058 , 0.02 , 0.959];   % group 1 compression
        xSte(2,:) = [0.999900 , 0.07085 , 0    , 0.959];   % group 2 equalizing
        xSte(3,:) = [0.999892 , 0.07087 , 0.02 , 0.959];   % group 3 reverb
        xSte(4,:) = [0.99990  , 0.07085 , 0.001 , 0.9585]; % group 4 positioning
        xSte(5,:) = [0.999899 , 0.07085 , 0.02 , 0.959];   % group 5 vocals
        featureData = mean(xSte,1);
        
    case 'surround.wav'
        % this needs to be "quite strongly" constructed
        revWfs = mean([0.999894; 0.999904; 0.999894; 0.999904; 0.9999021]);
        revSte = mean([0.999892; 0.999900; 0.999892; 0.99990 ; 0.999899 ]);
        deltaX = revWfs - revSte;
        deltaX = 2/3*deltaX;
        revSur = revSte + 2.9* deltaX;
        featureData = [revSur, 0.07091, 0.17, 0.97];
        
    case 'wfs_reference.wav'
        % deal with values for wfs(ref) condition, which are slightly different for each group
        xRef(1,:) = [0.999894 , 0.07115 , 0.76 , 0.980];   % group 1
        xRef(2,:) = [0.999904 , 0.0717  , 0.751, 0.980];   % group 2
        xRef(3,:) = [0.999894 , 0.07116 , 0.76 , 0.980];   % group 3
        xRef(4,:) = [0.999904 , 0.07114 , 0.76  , 0.980 ]; % group 4
        xRef(5,:) = [0.9999021, 0.07120 , 0.78 , 0.980];   % group 5
        featureData = mean(xRef,1);
        
    case 'wfs_compression_m1.wav'
        featureData   = [0.999886 , 0.07120 , 0.78 , 0.979];
    case 'wfs_compression_m2.wav'
        featureData  = [0.999882 , 0.07235 , 0.75 , 0.978];
    case 'wfs_compression_p1.wav'
        featureData   = [0.999903 , 0.0709  , 0.50 , 0.983];
    
    case 'wfs_equalizing_m1.wav'
        featureData   = [0.999901 , 0.0718  , 0.75 , 0.9799];
    case 'wfs_equalizing_m2.wav'
        featureData  = [0.999883 , 0.07148 , 0.6  , 0.978];
    case 'wfs_equalizing_p1.wav'
        featureData   = [0.999885 , 0.07135 , 0.8  , 0.978];
    
    case 'wfs_reverb_m1.wav'
        featureData   = [0.999906 , 0.07128 , 0.68 , 0.977];
    case 'wfs_reverb_m2.wav'
        featureData  = [0.999881 , 0.07158 , 0.63 , 0.975];
    case 'wfs_reverb_p1.wav'
        featureData   = [0.999906 , 0.07089 , 0.19 , 0.985];
    
    case 'wfs_positioning_m1.wav'
        featureData   = [0.999888 , 0.07139 , 0.63  , 0.977 ];
    case 'wfs_positioning_m2.wav'
        featureData  = [0.99987  , 0.07151 , 0.495 , 0.9645];
    case 'wfs_positioning_p1.wav'
        featureData   = [0.99990  , 0.07110 , 0.761 , 0.9795];
    case 'wfs_positioning_p2.wav'
        featureData  = [0.999885 , 0.07130 , 0.82  , 0.9798];
    
    case 'wfs_vocals_compression_equalizing_reverb_m1.wav'
        featureData   = [0.999902 , 0.07125 , 0.795, 0.980];
    case 'wfs_vocals_compression_equalizing_reverb_m2.wav'
        featureData  = [0.999875 , 0.0721  , 0.70 , 0.978];
    case 'wfs_vocals_compression_equalizing_p1.wav'
        featureData   = [0.9999022, 0.07119 , 0.79 , 0.981];
    case 'wfs_vocals_compression_equalizing_reverb_p1.wav'
        featureData   = [0.9999022, 0.07119 , 0.79 , 0.981]; % same as before
end