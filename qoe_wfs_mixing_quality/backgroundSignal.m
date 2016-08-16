function [sig, idx] = backgroundSignal(sig, fs);

[~, sig, ~, idx] = splitForegroundBackgroundSignal(sig, fs);
