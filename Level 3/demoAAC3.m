function [SNR, bitrate, compression] = demoAAC3(fNameIn, fNameOut, fnameAACoded)
% demoAAC3: Demonstrates the second level encoding 
% Output
% SNR: Signal-to-noise Ratio (dB) of the procedure
% bitrate: bits per sec
% compression: bitrate before encoding divided by  bitrate after encoding
% Input
% fNameIn: input file, to be encoded
% fNameOut: output file, the decoded
% fnameAACoded: .mat file to save the AACSeq3 sequence
%% Input 
audioIn = audioread(fNameIn);
%% Encode
AACSeq3 = AACoder3(fNameIn,fnameAACoded); 
%% Decode
audioOut = iAACoder3(AACSeq3,fNameOut);
%% Calculate noise and SNR.
commonLength = min(length(audioIn), length(audioOut));
audioIn = audioIn(1:commonLength,:);
audioOut = audioOut(1:commonLength,:);
noise = audioIn - audioOut;

SNR1 = snr(audioIn(:,1), noise(:,1));
SNR2 = snr(audioIn(:,2), noise(:,2));
SNR = (SNR1+SNR2)/2;
disp("SNR for the left channel is: ");
disp(SNR1);
disp("SNR for the right channel is: ");
disp(SNR2);
disp("Total SNR is: ");
disp(SNR);
%% Compression and bitrate
% Metadata of input
input = dir(fNameIn);
inputBytes = input.bytes;
inputBits = inputBytes * 8;
% Metadata of output
output = dir(fnameAACoded);
outputBytes = output.bytes;
outputBits = outputBytes * 8;
%% Output
compression = outputBits / inputBits;
bitrate = outputBits/((length(audioOut)/48000));
end

