function [pkt] = generatePacket(linkInfo, link, length, timeStamp, src, dst)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.linkInfo = linkInfo; % contains index of the struct which conatains the src and dst and more info about the link (it's one directional)
    pkt.link = link; % the linkInfo struct itself
    pkt.length = length;
    pkt.timeStamp = timeStamp;
    pkt.src = src;
    pkt.dst = dst;
    pkt.ind = -1; % for future use in the output
    
end