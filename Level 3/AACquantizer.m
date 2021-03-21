function [S, sfc, G] = AACquantizer(frameF, frameType, SMR)
% AACquantizer
% Calculates the threshold T(b) and implements Quantizer for each channel
% Output:
% S: Quantization symbols of MDCT coefficients for the current frame (1024 x 1)
% sfc: Scalefactor coefficients for each scalefactor band (Nb x 8 for ESH, Nb x 1 for other frame types)
% G: Global gain of the current frame (1x8 for ESH, 1 value for other frame types)
% Input:
% frameF: frame at the frequency domain - MDCT coefficients
% frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
% SMR: Signal to Mask Ratio 42x8 for ESH, 69x1 for other frameType
%% Import the band table
    data = importdata("TableB219.mat");
    if frameType == "ESH"
       bandTable = data.B219b;
       bandTable(:,1:3) = bandTable(:,1:3)+1;
    else
       bandTable = data.B219a;
       bandTable(:,1:3) = bandTable(:,1:3)+1;
    end
%%  Band Table 
w_low = bandTable(:,2);
w_high = bandTable(:,3);
%% Prepare the output variables
NB = length(bandTable);
[rows, cols] = size(frameF);
G = zeros(1, cols);
sfc = zeros(NB, cols);
S = zeros(rows, cols);
%%
colIndex = 1;
for f = frameF
%% 13 -  Calculate threshold T(b)
%  13th Step Of psycho.m
bb = 1:NB;
P = zeros(NB,1);
for b = bb
    index = w_low(b):w_high(b);
    P(b) = sum(f(index).^2);
end
T = P ./ SMR(:, colIndex);
%% Scalefactor Gain
%% Initial Value
MQ = 8191;
aHat = floor( (16/3) * log2((max(f)^(3/4))/ MQ));
aHat = ones(NB, 1) * aHat;
%% Optimization
while 1
    a_b = aHat;
    a_s = zeros(size(f));
    for b = bb
        index = w_low(b):w_high(b);
        a_s(index) = a_b(b);
    end
    S = quant(f, a_s);
    Xhat = dequant(S, a_s);
    Pe = zeros(NB,1);
    err = f - Xhat;
    for b = bb
         index = w_low(b):w_high(b);
         Pe(b) = sum(err(index).^2);
    end
    aHat = a_b + (Pe < T);
    if (aHat == a_b)
        break;
    end
    if (max(abs(diff(aHat))) > 60)
        break;
    end
end
%% Output 
G(colIndex) = a_b(1);
sfc(:, colIndex) = [a_b(1); diff(a_b)];
S(:, colIndex)  = quant(f, a_s);
%% In case of subframes
colIndex = colIndex + 1;
end
%% S is 1024 x 1 for every frameType
S = S(:);
end
%% Quantization Function
function S = quant(Xk, a)
MagicNumber = 0.4054;
S = sign(Xk) .* round( (abs(Xk) .* 2.^(- 1 / 4 * a)).^(3/4) + MagicNumber ); 
end
%% Dequantization Function
function Xk = dequant(S, a)
Xk = sign(S) .* (abs(S).^(4/3)).*2.^(1 / 4 * a);
end
