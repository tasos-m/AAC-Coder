function frameType = SSC(frameT, nextFrameT, prevFrameType)
% Sequence Segmentation Control function
% Output:
% frameType: the frame type of the i-th frame 
% Input:
% frameT: samples of the current frame
% nextFrameT: samples of the next frame 
% prevFrameType: the type of the previous frame
% Frame Types "OLS","ESH", "LSS", "LPS"
%% Check Frame Size 
if length(frameT) ~= 2048 
    disp("Frame hasn't the right size");
    return;
end
%% Previous frame type: LSS or LPS 
if prevFrameType == "LSS"
    frameType = "ESH";
    return;
elseif prevFrameType == "LPS"
    frameType = "OLS";
    return;
end   
%% Check if the next frame type is ESH (for each channel)
s_squared  = NaN(8,2);
ds_squared = zeros(8,2);
channelIsESH = NaN(2,1);
for channel = 1:2
    %% 1 - Filter the next frame with  a highpass digital filter H(z)
    b = [0.7548, -0.7548];
    a = [1, -0.5095];
    nextFrameFiltered = filter(b, a, nextFrameT(:,channel));
    %% 2 - Energy 
    index = 577:1600;
    for j = 0:7
        s_squared(j+1,channel) = sum(nextFrameFiltered(index(j*128+1:j*128+128)).^2);
    end
    %% 3 - Attack values
    for l = 2:8 
        ds_squared(l,channel) = s_squared(l,channel)/(sum(s_squared(1:l-1,channel)) / (l-1)); % edw kati periergo me tous deiktes 
    end
    %% 4 - Conditions
    channelIsESH(channel) =  any((s_squared(:,channel) > 0.001) & (ds_squared(:,channel) > 10));
end
%% Calculate the frame type for each channel
channelFrameType = strings([2 1]);
for channel = 1:2
    if prevFrameType == "OLS"
        if channelIsESH(channel)
            channelFrameType(channel) = "LSS";
        else
            channelFrameType(channel) = "OLS";
        end
    elseif prevFrameType == "ESH"
        if channelIsESH(channel)
            channelFrameType(channel) = "ESH";
        else
            channelFrameType(channel) = "LPS";
        end   
    end
end
%% Common Final Type
frameType = commonFinalType(channelFrameType(1),channelFrameType(2));
end
%% Calculate the Common Final Type
function common = commonFinalType(channel0,channel1)
ch0 = ["OLS" "OLS" "OLS" "OLS" "LSS" "LSS" "LSS" "LSS" "ESH" "ESH" "ESH" "ESH" "LPS" "LPS" "LPS" "LPS" ]'; 
ch1 = ["OLS" "LSS" "ESH" "LPS" "OLS" "LSS" "ESH" "LPS" "OLS" "LSS" "ESH" "LPS" "OLS" "LSS" "ESH" "LPS" ]';
commonType = ["OLS" "LSS" "ESH" "LPS" "LSS" "LSS" "ESH" "ESH" "ESH" "ESH" "ESH" "ESH" "LPS" "ESH" "ESH" "LPS" ]';
% Desicion Table
decision = [ch0 ch1 commonType];
ind0 = find((decision(:,1) == channel0));
ind1 = find((decision(:,2) == channel1));
% Find the line of the table where the first channel type equals channel0,
% and the second channel type equals channel1, so the result is  the final 
% common type
common = decision(intersect(ind0,ind1),3);
end