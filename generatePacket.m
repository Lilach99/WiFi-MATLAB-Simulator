function [pkt] = generatePacket(linkInfo, legth, timeStamp, src, dst)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.linkInfo = linkInfo; % contains the src and dst and more info about the link
    pkt.src = src;
    pkt.dst = dst;
    pkt.legth = legth;
    pkt.timeStamp = timeStamp;
    
end