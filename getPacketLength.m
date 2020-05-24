function [pktLen] = getPacketLength(linkInfo, devState)
    %returns a packet length according to the data in linkInfo
    
    switch linkInfo.pktPolicy
        case pktPolicy.CBR
            % constant bit rate, means constant packet size! say
            pktLen = 1460; % bytes
            % for packets aggregation experiments:
            STRatio = devState.ST/(9*10^-6); % ratio between the standard ST and the current device's ST (assuming current ST > standard ST)
            pktLen = pktLen * STRatio;
            
        case pktPolicy.RAND
            pktLen = randi([linkInfo.minPS, linkInfo.maxPS]);
    end

end

