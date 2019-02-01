% Load critical values of the t-distribution to compute correct confidence 
% intervals using Appendix A.2 of Andy Field, 
% Discovering Statistics using SPSS, 3rd edition, 2009, pp 803

function critT = getCritValTdist(df, level, tails)

if nargin < 3
    tails = 2;
end
if nargin < 2
    level = 0.05;
end
if nargin < 1
    df = 101;
end

dfVec = [1:30 35 40 45 50 60:10:100]';

% find row in tabulated data
if df<= 100
    pos = find(df <= dfVec);
    rowID = pos(1);
else
    rowID = 40;
end

% generate tabulated data
if (level == 0.05) && (tails == 2)
    critTvec = [12.71 4.3 3.18 2.78 2.57 2.45 2.36 2.31 2.26 2.23 2.2 2.18 2.16 2.14 2.13 2.12 2.11 2.1 2.09 2.09 2.08 2.07 2.07 2.06 2.06 2.06 2.05 2.05 2.05 2.04 2.03 2.02 2.01 2.01 2 1.99 1.99 1.99 1.98 1.96];
elseif (level == 0.01) && (tails == 2)
    critTvec = [63.66 9.92 5.85 4.6 4.03 3.71 3.5 3.36 3.25 3.17 3.11 3.05 3.01 2.98 2.95 2.92 2.9 2.88 2.86 2.85 2.83 2.82 2.81 2.8 2.79 2.78 2.77 2.76 2.76 2.75 2.72 2.7 2.69 2.68 2.66 2.65 2.64 2.63 2.63 2.58];
elseif (level == 0.05) && (tails == 1)
    critTvec = [6.31 2.92 2.35 2.13 2.02 1.94 1.86 1.86 1.83 1.81 1.8 1.78 1.77 1.76 1.75 1.75 1.74 1.73 1.73 1.72 1.72 1.72 1.71 1.71 1.71 1.71 1.7 1.7 1.7 1.7 1.69 1.68 1.68 1.68 1.67 1.67 1.66 1.66 1.66 1.64];
elseif (level == 0.01) && (tails == 1)
    critTvec = [31.82 6.96 4.54 3.75 3.36 3.14 3 2.9 2.82 2.76 2.72 2.68 2.65 2.62 2.6 2.58 2.57 2.55 2.54 2.53 2.52 2.51 2.5 2.49 2.49 2.48 2.47 2.47 2.46 2.46 2.44 2.42 2.41 2.4 2.39 2.38 2.37 2.37 2.36 2.33];
end

% choose critT from tabulated data
critT = critTvec(rowID);

