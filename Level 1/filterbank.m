function frameF = filterbank(frameT, frameType, winType)
% Filterbank
% Output:
% frameF: frame at the frequency domain - MDCT coefficients
% Input:
% frameT: samples of the current frame
% frameType: the frame type of the current frame
% winType: The window type, applied at the current frame
% winType is SIN or KBD for all frames in this simplified version of AAC 
%% Length of the current frame
N = length(frameT);
%% Create a short and a long window given the window Type
if winType == "SIN" 
    longWindow = windowSIN(N);
    shortWindow = windowSIN(N/8);
elseif winType == "KBD" 
    longWindow = windowKBD(N,4); 
    shortWindow = windowKBD(N/8,6);
else
    disp("Wrong Type of filter");
    return;
end
%% FrameF
% Procedure of 
if frameType == "OLS"
    frameT = frameT .* longWindow;
    frameF = MDCT(frameT);
elseif frameType == "LSS"
    win = [longWindow(1:1024,:); ones(448,2); shortWindow(129:256,:); zeros(448,2)];
    frameT = frameT .* win;
    frameF = MDCT(frameT);
elseif frameType == "ESH"
    for i = 0:7
        indexSplit = 448 + i * 128 + (1:256);
        indexFinal = i * 128 + (1:128);
        subframe = frameT(indexSplit,:);
        subframe = subframe .* shortWindow;
        frameF(indexFinal,:) = MDCT(subframe); % mipws ena ena ta channel, check kapoia stigmi
    end
elseif frameType == "LPS"
    win = [zeros(448,2); shortWindow(1:128,:); ones(448,2); longWindow(1025:2048,:)];
    frameT = frameT.*win;
    frameF = MDCT(frameT);   
end
end
%% MDCT Function
function y = MDCT(x)
% Using Marios Athineos MDCT4 function with a few adjustments 
[rows, cols] = size(x);

% Make sure length is multiple of 4
if (mod(rows, 4) ~= 0)
    error('MDCT4 defined for lengths multiple of four.');
end


N = rows;  % Length of window
M = N / 2; % Number of coefficients
N_4 = N / 4;

% Preallocate rotation matrix
rotationMatrix = zeros(rows, cols);

% Shift
t = (0:(N_4 - 1))';
rotationMatrix(t+1,:) = -x(t+3*N_4+1,:);
t = (N_4:(N - 1))';
rotationMatrix(t+1,:) = x(t-N_4+1,:);

% We need this twice so keep it around
t = (0:(N_4 - 1))';
w = diag(sparse(exp(-1i*2*pi*(t + 1 / 8)/N)));

% Pre-twiddle
t = (0:(N_4 - 1))';
c = (rotationMatrix(2*t+1,:) - rotationMatrix(N-1-2*t+1,:)) - 1i * (rotationMatrix(M+2*t+1,:) - rotationMatrix(M-1-2*t+1,:));
c = 0.5 * w * c;

% FFT for N/4 points only 
c = fft(c, N_4);

% Post-twiddle
c = (2 / sqrt(N)) * w * c;

% Sort
t = (0:(N_4 - 1))';
y(2*t+1,:) = real(c(t+1,:));
y(M-1-2*t+1,:) = - imag(c(t+1,:));
end
%% KBD Window
function win = windowKBD(N,a)
win = kbdwin(N,a);
win = [win win];
end
%% SIN Window
function win = windowSIN(N)
x = 0:N - 1;
win1 = sin(pi / N * (x + 0.5));
win = [win1' win1'];
end