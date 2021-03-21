function [frameFout, TNScoeffs] = TNS(frameFin, frameType)
% TNS: Temporal Noise Shaping 
% Output: 
% frameFout: MDCT coefficients after Temporal Noise Shaping
% table 128x8 for ESH, 1024x1 for the other frame types
% TNScoeffs: Quantized TNS coefficients 
% table 4x8 for ESH, 4x1 for the other frame types
% Input:
% frameFin: MDCT coefficients before Temporal Noise Shaping
% table 128x8 for ESH, 1024x1 for the other frame types
% frameType: the type of the current frame (OLS,ESH,LSS,LPS)
%% Import the band table    
data = importdata("TableB219.mat");
if frameType == "ESH"
   bandTable = data.B219b;
   bandTable(:,1:3) = bandTable(:,1:3)+1;
else
   bandTable = data.B219a;
   bandTable(:,1:3) = bandTable(:,1:3)+1;
end
%% Band Table 
w_low = bandTable(:,2);
w_high = bandTable(:,3);
NB = length(bandTable);
%% Output
[rows, cols] = size(frameFin);
frameFout = zeros(rows, cols);
TNScoeffs = zeros(4,cols);
colIndex = 1;
for X = frameFin
    %% 1. Normalization of MDCT Coefficients and Smoothing
    Sw = zeros(rows, 1); 
    for j = 1 : NB 
        index = w_low(j):w_high(j);
        Pj = sum(X(index).^2);
        Sw(index) = sqrt(Pj);
    end
    % Smoothing
    for k = length(Sw) - 1 : -1 : 1
        Sw(k) = (Sw(k) + Sw(k+1)) / 2;
    end
    for k = 2 : length(Sw)
        Sw(k) = (Sw(k) + Sw(k-1)) / 2;
    end
    Xw = X ./ Sw;        
    %% 2. Linear Prediction
    % lpc function of matlab solves the linear prediction problem
    a1 = lpc(Xw, 4);
    % dont use the intercept
    a = - a1(2:end);
    %% 3. Quantize
    % 4 bits Uniform Symmetric Quantizer using 0.1 step
    a = round(a*10)/10;
    % For bigger or lower values assign 0.8 or -0.7 accordingly
    idx = find(a>0.8);
    a(idx) = 0.8;
    idx = find(a<-0.7);    
    a(idx) = -0.7;
    %% 4. FIR Filtering
    a = [1 -a];
    %% Filter and TNS Coefficients
    frameFout(:, colIndex) = filter(a, 1, X);
    TNScoeffs(:, colIndex) = -a(2:end);
    %% In case of subframes
    colIndex = colIndex + 1;
end
end

