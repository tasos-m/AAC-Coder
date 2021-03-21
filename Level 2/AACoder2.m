function AACSeq2 = AACoder2(fNameIn)
% AACoder2: Encoder for the second level
% Output:
% AACSeq2: output struct that contains
% *frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
% *winType:  The window type, applied at each frame
% *chl.frameF: frameF of the left channel
% *chr.frameF: frameT of the right channel
% *chl.TNScoeffs: TNScoeffs of the left channel
% *chr.TNScoeffs: TNScoeffs of the right channel
% Input:
% fNameIn: the file to be encoded
%% Given Parameters for the encoding
winType = "KBD";    % Window used for perfect reconstruction
frameLength = 2048; % Length of the overlaped frames
overlap = 0.5;      % Percentage of overlapping
prevType = "OLS";   % Considering that the firt frame is ONLY_LONG_SEQUENCE
%% Import the audio file
audioIn = audioread(fNameIn);
N = length(audioIn);
modulo = mod(N,frameLength); 
%% Zero Padding
% The input should be divisible by the length of the frames, so pad with 
% zeros equal to (2048 - modulo). Also pad a half frame of zeros before the start 
% of the signal and another half after the end of it
audioIn = [zeros(frameLength/2, 2); audioIn ; zeros(2048 - modulo  + frameLength/2, 2)];
N = length(audioIn);
%% Output struct
AACSeq2 = struct('frameType', {}, 'winType', {},...
    'chl', struct('frameF', {},'TNSCoeffs',{}),...
    'chr', struct('frameF', {},'TNSCoeffs',{}));
%% Encoding
frames = ( 1 / overlap ) * ( N / frameLength - 1 );
for frameIndex = 0 : frames - 1
    frameTIndex = (frameIndex * frameLength * overlap + 1):...
        ( frameIndex * frameLength * overlap + 1 + frameLength -1);
    nextFrameTIndex = ((frameIndex+1) * frameLength * overlap + 1):...
        ((frameIndex+1) * frameLength * overlap  + 1 + frameLength -1);
    frameT = audioIn(frameTIndex,:);
    nextFrameT = audioIn(nextFrameTIndex,:);
    
    prevType = SSC(frameT,nextFrameT,prevType);
    
    AACSeq2(frameIndex+1).frameType = prevType;
    AACSeq2(frameIndex+1).winType = winType;
    
    frameF = filterbank(frameT, prevType, winType);
    if prevType == "ESH"
        AACSeq2(frameIndex+1).chl.frameF = reshape(frameF(:, 1),[128 8]);
        AACSeq2(frameIndex+1).chr.frameF = reshape(frameF(:, 2),[128 8]);  
    else
        AACSeq2(frameIndex+1).chl.frameF = frameF(:, 1);
        AACSeq2(frameIndex+1).chr.frameF = frameF(:, 2);  
    end
    [AACSeq2(frameIndex+1).chl.frameF, AACSeq2(frameIndex+1).chl.TNScoeffs] = ...
        TNS(AACSeq2(frameIndex+1).chl.frameF, prevType);
    [AACSeq2(frameIndex+1).chr.frameF, AACSeq2(frameIndex+1).chr.TNScoeffs] = ...
        TNS(AACSeq2(frameIndex+1).chr.frameF, prevType);    
  
end
end

