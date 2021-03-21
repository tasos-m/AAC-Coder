function frameFout = iTNS(frameFin, frameType, TNScoeffs)
% iTNS: Inverse Temporal Noise Shaping 
% Output: 
% frameFout: MDCT coefficients after  inverse Temporal Noise Shaping
% table 128x8 for ESH, 1024x1 for the other frame types
% Input:
% frameFin: MDCT coefficients before inverse Temporal Noise Shaping
% table 128x8 for ESH, 1024x1 for the other frame types
% frameType: the type of the current frame (OLS,ESH,LSS,LPS)
% TNScoeffs: Quantized TNS coefficients 
% table 4x8 for ESH, 4x1 for the other frame types
[rows, cols] = size(frameFin);
frameFout = zeros(rows,cols);
for i = 1 : cols
    a = [1, -TNScoeffs(:,i)'];
    frameFout(:,i) = filter(1,a,frameFin(:,i));
end
end

