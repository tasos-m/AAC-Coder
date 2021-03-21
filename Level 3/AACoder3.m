function AACSeq3 = AACoder3(fNameIn, fnameAACoded)
% AACoder3: Encoder for the second level
% Output:
% AACSeq3: output struct that contains
% * frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
% * winType:  The window type, applied at each frame
% * chl.TNScoeffs: TNScoeffs of the left channel
% * chr.TNScoeffs: TNScoeffs of the right channel
% * chl.T: Thresholds of psychoacoustic model for the left channel 
% * chr.T: Thresholds of psychoacoustic model for the right channel
% * chl.G: Quantized global gains for the left channel
% * chr.G: Quantized global gains for the right channel
% * chl.sfc: Encoded sfc sequence for the left channel
% * chr.sfc: Encoded sfc sequence for the right channel
% * chl.stream: Encoded sequence of MDCT coefficients for the left channel
% * chr.stream: Encoded sequence of MDCT coefficients for the right channel
% * chl.codebook: Huffman codebook used for the left channel
% * chr.codebook: Huffman codebook used for the right channel
% Input:
% fNameIn: the file to be encoded
% fnameAACoded: .mat file to save the AACSeq3 sequence
%% Given Parameters for the encoding
winType = "SIN";    % Window used for perfect reconstruction
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
AACSeq3 = struct('frameType', {}, 'winType', {},...
    'chl', struct('TNScoeffs', {}, 'T', {}, ...
    'G', {}, 'sfc', {}, 'stream', {}, 'codebook', {}),...
    'chr', struct('TNScoeffs', {}, 'T', {}, 'G', {},...
    'sfc', {}, 'stream', {}, 'codebook', {}));
%% Encoding
frames = ( 1 / overlap ) * ( N / frameLength - 1 );
huffLUT = loadLUT();
frameT = zeros(frameLength, 2);
frameTprev1 = zeros(frameLength, 2);
for frameIndex = 0 : frames - 1
    frameTprev2 = frameTprev1;
    frameTprev1 = frameT;
    frameTIndex = (frameIndex * frameLength * overlap + 1):...
        ( frameIndex * frameLength * overlap + 1 + frameLength -1);
    nextFrameTIndex = ((frameIndex+1) * frameLength * overlap + 1):...
        ((frameIndex+1) * frameLength * overlap  + 1 + frameLength -1);
    frameT = audioIn(frameTIndex,:);
    nextFrameT = audioIn(nextFrameTIndex,:);
    
    prevType = SSC(frameT,nextFrameT,prevType);
    
    AACSeq3(frameIndex+1).frameType = prevType;
    AACSeq3(frameIndex+1).winType = winType;
    
    frameF = filterbank(frameT, prevType, winType);
    if prevType == "ESH"
        frameFLeft = reshape(frameF(:, 1),[128 8]);
        frameFRight = reshape(frameF(:, 2),[128 8]);  
    else
        frameFLeft = frameF(:, 1);
        frameFRight = frameF(:, 2);  
    end
    %% TNS
    % Left Channel
    [frameFLeft, AACSeq3(frameIndex+1).chl.TNScoeffs] = ...
        TNS(frameFLeft, prevType);
    % Right channel
    [frameFRight, AACSeq3(frameIndex+1).chr.TNScoeffs] = ...
        TNS(frameFRight, prevType);
    %% Psycho, AACquantizer, encodeHuff
    % Left Channel
    SMR = psycho(frameT(:, 1), prevType, frameTprev1(:, 1), frameTprev2(:, 1));
    [S, sfc, AACSeq3(frameIndex+1).chl.G] = AACquantizer(frameFLeft, prevType, SMR);
    AACSeq3(frameIndex+1).chl.sfc = encodeHuff(sfc(:), huffLUT, 12);
    [AACSeq3(frameIndex+1).chl.stream, AACSeq3(frameIndex+1).chl.codebook] = encodeHuff(S, huffLUT);   
    % Right channel
    SMR = psycho(frameT(:, 2), prevType, frameTprev1(:, 2), frameTprev2(:, 2));
    [S, sfc, AACSeq3(frameIndex+1).chr.G] = AACquantizer(frameFRight, prevType, SMR);
    AACSeq3(frameIndex+1).chr.sfc = encodeHuff(sfc(:), huffLUT, 12);
    [AACSeq3(frameIndex+1).chr.stream, AACSeq3(frameIndex+1).chr.codebook] = encodeHuff(S, huffLUT);    
end
%% Save the .mat file
save(fnameAACoded, 'AACSeq3');
end

