function SNR = demoAAC1(fNameIn, fNameOut)
% demoAAC1: Demonstrates the first level encoding 
% Output
% SNR: Signal-to-noise Ratio (dB) of the procedure
% Input
% fNameIn: input file, to be encoded
% fNameOut: output file, the decoded
%% Input
audioIn = audioread(fNameIn);
%% Encode
AACSeq1 = AACoder1(fNameIn);
%% Decode
audioOut = iAACoder1(AACSeq1,fNameOut);
%% Calculate noise and SNR.
commonLength = min(length(audioIn), length(audioOut));
audioIn = audioIn(1:commonLength,:);
audioOut = audioOut(1:commonLength,:);
noise = audioIn - audioOut;
%% SNR
SNR1 = snr(audioIn(:,1), noise(:,1));
SNR2 = snr(audioIn(:,2), noise(:,2));
SNR = (SNR1+SNR2)/2;
disp("SNR for the left channel is: ");
disp(SNR1);
disp("SNR for the right channel is: ");
disp(SNR2);
disp("Total SNR is: ");
disp(SNR);
end

