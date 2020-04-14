function [pkt] = generatePacket(linkInfo, length, timeStamp)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.linkInfo = linkInfo; % contains the src and dst and more info about the link (it's one directional)
    pkt.length = length;
    pkt.timeStamp = timeStamp;
    
end