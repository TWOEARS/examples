% Example script of how to extract foreground signal

% Load reference signal
[sig, fs] = audioread('stimuli/wfs_reference.wav');
% Use AFE to calculate adaptation output
dataObj = dataObject(sig, fs);
managerObj = manager(dataObj);
sOut = managerObj.addProcessor('adaptation');
managerObj.processSignal;
% Convolve with 20ms 1st order low pass and extract time 1.5s-4s
[b,a] = butter(1,Wn,'low');
Yl = filter(b,a,sOut{1}.Data(1.5*fs:4*fs,9)); % Use 500 Hz channel
Ylf = foregroundSignal(Yl, fs);
figure; plot(1:length(Yl),Yl,'-b',1:length(Yl),Ylf,'-r')
