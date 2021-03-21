function SMR = psycho(frameT, frameType, frameTprev1, frameTprev2)
% psycho: Psychoacoustic model for each channel 
% Output:
% SMR: Signal to Mask Ratio 42x8 for ESH, 69x1 for other frame types
% Input:
% frameT: samples of the current frame
% frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
% frameTprev1: previous frame of the frameT
% frameTprev2: previous frame of the frameTprev1
%% Import the band table and format the frames
data = importdata("TableB219.mat");
if frameType == "ESH"
   bandTable = data.B219b;
   bandTable(:,1:3) = bandTable(:,1:3)+1;
   frameT = vec2mat(frameT,256)'; % convert frame in a 256 x 8
   frameTprev1 = vec2mat(frameTprev1,256)';
   % in the case we have a ESH we use the two last subframes
   frameTprev2 = frameTprev1(:,end-1);
   frameTprev1 = frameTprev1(:,end);
else
   bandTable = data.B219a;
   bandTable(:,1:3) = bandTable(:,1:3)+1;
end
%%  Band Table 
w_low = bandTable(:,2);
w_high = bandTable(:,3);
bval = bandTable(:,5);
qsthr = bandTable(:,6);
%% Frame
% Size of the frame
[rows, cols] = size(frameT);
%% Spreading table
% Calculate the spreading table for every combination of indices to avoid
% calculating it inside the loop 
bb = 1 : length(bandTable); 
spreadingTable = zeros(size(bb));
for i = bb
    for j = bb
        spreadingTable(i, j) = spreadingfun(i, j, bval);
    end
end
%% Hann Window
N = length(frameT); %length of the window
hannWin = (0.5 - 0.5 * cos((pi*(0:N - 1))/(N)))';
%% Apply the second step of the algorithm to the previous frames
% Apply Hann Window
s_0 = frameTprev1 .* hannWin;
s_1 = frameTprev2 .* hannWin;
% Calculate FFT
y_0 = fft(s_0);
y_0 = y_0(1:end/2);
r_current = abs(y_0);
f_current = angle(y_0);
%
y_1 = fft(s_1);
y_1 = y_1(1:end/2);
r_1 = abs(y_1);
f_1 = angle(y_1);
%% w
w = 1:N / 2; 
SMR = zeros(length(bb), cols);
for colIndex  = 1 : cols
    %%
    r_2 = r_1;
    r_1 = r_current;
    f_2 = f_1;
    f_1 = f_current;    
    %% If ESH use each time the next subframe - For other types just the only frame
    frame = frameT(:, colIndex);
    %% Follow the steps of the algorithm
    %% 1 - Spreading Function
    %  Spreading function was calculated before the loop
    %% 2 - Hann Window and FFT
    % Hann Window
    s_current = frame .* hannWin;
    % FFT
    temp = fft(s_current);
    temp = temp(1:end/2);
    r_current = abs(temp);
    f_current = angle(temp);
    %% 3 - Calculate r, f predictions
    r_pred = 2*r_1(w) - r_2(w);
    f_pred = 2*f_1(w) - f_2(w);    
    %% 4 - Calculate the predictability measure c(w)
    c_w = sqrt( ...
        (r_current(w) .* cos(f_current(w)) - r_pred(w) .* cos(f_pred(w))).^2+ ...
        (r_current(w) .* sin(f_current(w)) - r_pred(w) .* sin(f_pred(w))).^2 ) ./ ...
        (r_current(w) + abs(r_pred(w)));    
    %% 5 - Calculate Energy and Predictibility
    e  = zeros(size(bb));
    c = zeros(size(bb));
    for b = bb
        index = w_low(b):w_high(b);
        e(b) = sum( r_current(index) .^ 2 );
        c(b) = sum( c_w(index) .* ( r_current(index) .^ 2) );
    end
    %% 6 - Combine Energy and Predictibility with the Spreading Function
    ecb =  zeros(size(bb));
    ct  =  zeros(size(bb));
    for b = bb
        ct(b) = sum( c(bb) * spreadingTable(bb, b) ); 
        ecb(b) = sum( e(bb) * spreadingTable(bb, b) );
    end
    cb = ct ./ ecb;
    en = ecb ./ sum(spreadingTable(bb,:));
    %% 7 - Tonality index for each band
    tb = - 0.299 - 0.43 * log(cb);
    %% 8 - Calculate SNR for each band
    TMN = 18;
    NMT = 6;
    SNR = tb * TMN + (1 - tb)* NMT;
    %% 9 - Convert dB to Energy Ratio
    bc = 10 .^ (-(SNR/10));
    %% 10 - Calculate the Energy Threshold 
    nb = en .* bc ; 
    %% 11 - Calculate the Noise Level
    qthr_hat = eps *(N/2)* 10.^(qsthr / 10);
    npart = max(nb, qthr_hat'); 
    %% 12 - Calculate Single to Mask Ratio - SMR
    SMR(:, colIndex) = e./npart;
    %% 13 - Calculate threshold T(b)
    % This step is done in the AACquantizer.m
end
end
%% Spreading Function
function  x = spreadingfun(i, j, bval)
    if  i >= j
        tmpx = 3*(bval(j) - bval(i));
    else
        tmpx = 1.5*(bval(j) - bval(i));
    end
    tmpz = 8 * min((tmpx-0.5)^2 -2*(tmpx-0.5), 0);
    tmpy = 15.811389 + 7.5*(tmpx + 0.474) - 17.5*(1.0 + (tmpx + 0.474)^2)^0.5;
    if tmpy < -100
        x = 0;
    else
        x = 10^((tmpz+tmpy)/10);
    end
end