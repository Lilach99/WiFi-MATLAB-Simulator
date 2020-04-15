function [pkt] = generatePacket(linkInfo, length, timeStamp, src, dst)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.linkInfo = linkInfo; % contains ind of the struct which conatains the src and dst and more info about the link (it's one directional)
    pkt.length = length;
    pkt.timeStamp = timeStamp;
    pkt.src = src;
    pkt.dst = dst;
    pkt.ind = -1; % for future use in the output
    
end