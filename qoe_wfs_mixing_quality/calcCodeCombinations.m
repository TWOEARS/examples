% function codeTable = calcCodeCombinations(base,numDigits)
% 
% Computes possible code combinations for a given base (number of symbols)
% and number of digits (length of words).
% 
% Example: base = 2, numDigits = 3
% codeTabe = [...
% 0 0 0 ;
% 0 0 1 ;
% 0 1 0 ;
% 0 1 1 ;
% 1 0 0 ;
% 1 0 1 ;
% 1 1 0 ;
% 1 1 1]
%
% Janto Skowronek
% 01 Sep 2010

function codeTable = calcCodeCombinations(base,numDigits)

numWords = base^numDigits;
codeTable = zeros(numWords,numDigits);

for digitIdx = 1 : numDigits
    columnVec = zeros(base^digitIdx,1);
    for baseIdx = 1 : base
        columnVec((base^(digitIdx-1)) * (baseIdx-1) + 1 : (base^(digitIdx-1)) * baseIdx) = repmat(baseIdx-1,base^(digitIdx-1),1);
    end
    codeTable(:,numDigits+1-digitIdx) = repmat(columnVec,numWords/length(columnVec),1);
end
