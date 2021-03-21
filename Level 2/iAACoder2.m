function x = iAACoder2(AACSeq2, fNameOut)
% iAACoder2: inverse function of AACoder2
% Decoder of the second level
% Ouput:
% x: decoded sequence
% Input:
% fNameOut: The decoded sequence will be saved in the fNameOut file
% AACSeq2: input struct that contains
% *frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
% *winType:  The window type, applied at each frame
% *chl.frameF: frameF of the left channel
% *chr.frameF: frameT of the right channel
% *chl.TNScoeffs: TNScoeffs of the left channel
% *chr.TNScoeffs: TNScoeffs of the right channel
%% 
frameLength = 2048;
encodedLength = length(AACSeq2);
decodedLength = (encodedLength + 1)*1024;
decodedAudio = zeros(decodedLength,2);
%% Decode
for i = 1:encodedLength
    leftframeF = iTNS(AACSeq2(i).chl.frameF, AACSeq2(i).frameType, AACSeq2(i).chl.TNScoeffs);
    rightframeF = iTNS(AACSeq2(i).chr.frameF, AACSeq2(i).frameType, AACSeq2(i).chr.TNScoeffs);
    if AACSeq2(i).frameType == "ESH"
        leftframeF = leftframeF(:);
        rightframeF = rightframeF(:);
    end
    frameF = [leftframeF rightframeF];
    frameT = iFilterbank(frameF, AACSeq2(i).frameType, AACSeq2(i).winType);
    decodedAudio((i-1)*1024+1:(i+1)*1024,:) = decodedAudio((i-1)*1024+1:(i+1)*1024,:) + frameT(1:2048,:);
end
%% Remove Padding
decodedAudio = decodedAudio(frameLength/2 + 1 : end - frameLength/2,:);
%% Output
f_s = 48e3; % Sample Frequency
audiowrite(fNameOut, decodedAudio, f_s);
if nargout == 1
    x = decodedAudio;
end
end

