function [pkt] = generatePacket(src, dst, legth, timeStamp)
    %creates a packet with the specified fields values
    pkt.type = packetType.DATA;
    pkt.src = src;
    pkt.dst = dst;
    pkt.legth = legth;
    pkt.timeStamp = timeStamp;
    
end