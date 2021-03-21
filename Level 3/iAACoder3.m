function x = iAACoder3(AACSeq3, fNameOut)
% iAACoder2: inverse function of AACoder2
% Decoder of the third level
% Ouput:
% x: decoded sequence
% Input:
% fNameOut: The decoded sequwnxe will be saved in the fNameOut file
% AACSeq3: input struct that contains
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
%% 
frameLength = 2048;
encodedLength = length(AACSeq3);
decodedLength = (encodedLength + 1)*1024;
decodedAudio = zeros(decodedLength,2);
huffLUT = loadLUT();
%% Decode
for i = 1:encodedLength
    frameType = AACSeq3(i).frameType;
    %% Left Channel
    sfc = decodeHuff(AACSeq3(i).chl.sfc, 12, huffLUT);
    S = decodeHuff(AACSeq3(i).chl.stream, AACSeq3(i).chl.codebook, huffLUT);
    if frameType == "ESH"
        sfc = reshape(sfc, [42 8]);
        S = reshape(S, [128 8]);
    else        
        sfc = sfc(:); 
        S = S(:); 
    end
    leftframeF = iAACquantizer(S, sfc, AACSeq3(i).chl.G, frameType);
    %% Right Channel
    sfc = decodeHuff(AACSeq3(i).chr.sfc, 12, huffLUT);
    S = decodeHuff(AACSeq3(i).chr.stream, AACSeq3(i).chr.codebook, huffLUT);
    if frameType == "ESH"
        sfc = reshape(sfc, [42 8]);
        S = reshape(S, [128 8]);
    else        
        sfc = sfc(:); 
        S = S(:); 
    end
    rightframeF = iAACquantizer(S, sfc, AACSeq3(i).chr.G, frameType);
    %% iTNS
    leftframeF = iTNS(leftframeF, AACSeq3(i).frameType, AACSeq3(i).chl.TNScoeffs);
    rightframeF = iTNS(rightframeF, AACSeq3(i).frameType, AACSeq3(i).chr.TNScoeffs);
   
    if frameType == "ESH"
        leftframeF = leftframeF(:);
        rightframeF = rightframeF(:);
    end
    frameF = [leftframeF rightframeF];
    frameT = iFilterbank(frameF, AACSeq3(i).frameType, AACSeq3(i).winType);

    decodedAudio((i-1)*1024+1:(i+1)*1024,:) = decodedAudio((i-1)*1024+1:(i+1)*1024,:) + frameT(1:2048,:);
end
%% Remove Padding
decodedAudio = decodedAudio(frameLength/2 + 1 : end - frameLength/2,:);
%% Normalization
decodedAudio(:, 1) = decodedAudio(:, 1) ./ max(abs(decodedAudio(:, 1)));
decodedAudio(:, 2) = decodedAudio(:, 2) ./ max(abs(decodedAudio(:, 2)));
%% Output
f_s = 48e3; % Sample Frequency
audiowrite(fNameOut, decodedAudio, f_s);
if nargout == 1
    x = decodedAudio;
end
end