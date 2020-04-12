function [pkt] = emptyPacket()
    %generates an "empty" packet
    %   this is a packet whose all fields are 'NONE' 
    
    pkt.type = packetType.NONE;
    pkt.src = packetType.NONE;
    pkt.dst = packetType.NONE;
    pkt.legth = packetType.NONE;
    pkt.timeStamp = packetType.NONE;
    
end