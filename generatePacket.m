function [pkt] = generatePacket(linkInd, length, timeStamp)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.linkInd = linkInd; % the index of the cell in the linksInfo cell array, which contains the src and dst and more info about the link (it's one directional)
    pkt.length = length;
    pkt.timeStamp = timeStamp;
    
end