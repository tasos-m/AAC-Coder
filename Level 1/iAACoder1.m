function x = iAACoder1(AACSeq1, fNameOut)
% iAACoder1: inverse function of AACoder1
% Decoder of the first level
% Ouput:
% x: decoded sequence
% Input:
% fNameOut: The decoded sequwnxe will be saved in the fNameOut file
% AACSeq1: output struct that contains
% *frameType: the frame type of each frame(OLS,ESH,LSS,LPS)
% *winType:  The window type, applied at each frame
% *chl.frameF: frameF of the left channel
% *chr.frameF: frameT of the right channel
%% 
frameLength = 2048;
encodedLength = length(AACSeq1);
decodedLength = (encodedLength + 1)*1024;
decodedAudio = zeros(decodedLength,2);
%% Decode
for i = 1:encodedLength
    frameF = [AACSeq1(i).chl.frameF AACSeq1(i).chr.frameF];
    frameT = iFilterbank(frameF,AACSeq1(i).frameType,AACSeq1(i).winType);
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

