function frameF = iAACquantizer(S, sfc, G, frameType)
% iAACquantizer
% Implements the iQuantizer level
% Output:
% frameF: frame at the frequency domain - MDCT coefficients
% Input:
% S: Quantization symbols of MDCT coefficients for the current frame (1024 x 1)
% sfc: Scalefactor coefficients for each scalefactor band (Nb x 8 for ESH, Nb x 1 for other frame types)
% G: Global gain of the current frame (1x8 for ESH, 1 value for other frame types)
% frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
%% Check if G equals with the first row of sfc
if G ~= sfc(1,:)
    disp("Wrong")
    return;
end
%% Import the band table and format the frameF
data = importdata("TableB219.mat");
if frameType == "ESH"
   bandTable = data.B219b;
   bandTable(:,1:3) = bandTable(:,1:3)+1;
   cols = 8;
   frameF = zeros(128,8);
else
   bandTable = data.B219a;
   bandTable(:,1:3) = bandTable(:,1:3)+1;
   frameF = zeros(1024,1);
   cols = 1;
end
%%  Band Table 
w_low = bandTable(:,2);
w_high = bandTable(:,3);
NB = length(bandTable);
%%
for colIndex = 1:cols
    a = cumsum(sfc(:,colIndex));
    bb = 1:NB;
    a_s = zeros(1024/cols,1);
    for b = bb
        index = w_low(b):w_high(b);
        a_s(index) = a(b);
    end
    frameF(:, colIndex) = dequant(S(:, colIndex), a_s);
end
end
%% Dequantization Function
function Xk = dequant(S, a)
Xk = sign(S) .* (abs(S).^(4/3)).*2.^(1 / 4 * a);
end
