function [pkt] = generatePacket(linkInfo, legth, timeStamp)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.linkInfo = linkInfo; % contains the src and dst and more info about the link (it's one directional)
    pkt.legth = legth;
    pkt.timeStamp = timeStamp;
    
end