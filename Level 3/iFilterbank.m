function frameT = iFilterbank(frameF, frameType, winType)
% iFilterbank: inverse function of filterbank
% converts the frameF to frameT
% Output:
% frameT: samples of the current frame at time domain
% Input"
% frameF:  frame at the frequency domain - MDCT coefficients
% frameType: the type of the current frame
% winType: The window type, applied at the current frame
% winType is SIN or KBD for all frames in this simplified version of AAC 
%% Ν
N = 2 * length(frameF);
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
%% FrameT
if frameType == "OLS"
    frameT = IMDCT(frameF);
    frameT = frameT .* longWindow;
elseif frameType == "LSS"
    win = [longWindow(1:1024,:); ones(448,2); shortWindow(129:256,:); zeros(448,2)];
    frameT = IMDCT(frameF);    
    frameT = frameT .* win;
elseif frameType == "ESH"
    frameT = zeros(N,2);
    for i = 0:7
        indexFrameT = 448 + i * 128 + (1:256);
        indexFrameF = i * 128 + (1:128);
        subframeF = frameF(indexFrameF,:);
        subframeT = IMDCT(subframeF); % mipws ena ena ta channel, check kapoia stigmi
        subframeT = subframeT .* shortWindow;
        frameT(indexFrameT,:) = frameT(indexFrameT,:) + subframeT;
    end
elseif frameType == "LPS"
    win = [zeros(448,2); shortWindow(1:128,:); ones(448,2); longWindow(1025:2048,:)];
    frameT = IMDCT(frameF);   
    frameT = frameT.*win;
end
end

function y = IMDCT(x)
% Using Marios Athineos IMDCT4 function with a few adjustments 


[rows, cols] = size(x);
% We need these for furmulas below
N = rows;
M = N / 2;

% We need this twice so keep it around
t = (0:(M - 1))';
w = diag(sparse(exp(-1i*2*pi*(t + 1 / 8)/(2*N))));

% Pre-twiddle
t = (0:(M - 1))';
c = x(2*t+1,:) + 1i * x(N-1-2*t+1,:);
c = (0.5 * w) * c;

% FFT for N/2 points only !!!
c = fft(c, M);

% Post-twiddle
c = ((8 / sqrt(2*N)) * w) * c;

% Preallocate rotation matrix
rotationMatrix = zeros((2*N), cols);

% Sort
t = (0:(M - 1))';
rotationMatrix(2*t+1,:) = real(c(t+1,:));
rotationMatrix(N+2*t+1,:) = imag(c(t+1,:));
t = (1:2:((2*N) - 1))';
rotationMatrix(t+1,:) = -rotationMatrix((2*N)-1-t+1,:);

% Shift
t = (0:(3 * M - 1))';
y(t+1,:) = rotationMatrix(t+M+1,:);
t = (3 * M:((2*N) - 1))';
y(t+1,:) = - rotationMatrix(t-3*M+1,:);
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