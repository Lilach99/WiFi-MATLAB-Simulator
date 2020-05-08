function [pktLen] = getPacketLength(linkInfo)
    %returns a packet length according to the data in linkInfo
    
    switch linkInfo.pktPolicy
        case pktPolicy.CBR
            % constant bit rate, means constant packet size! say
            pktLen = 1460; % bytes
            
        case pktPolicy.RAND
            pktLen = randi([linkInfo.minPS, linkInfo.maxPS]);
    end

end

