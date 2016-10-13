function [sig, idx] = foregroundSignal(sig, fs);

[sig, ~, idx, ~] = splitForegroundBackgroundSignal(sig, fs);
