function [pkt] = emptyPacket()
    %generates an "empty" packet
    %   this is a packet whose all fields are 'NONE' 
    
    persistent emptyPkt
        
    if isempty(emptyPkt)
        emptyPkt.type = packetType.NONE;
        emptyPkt.src = packetType.NONE;
        emptyPkt.dst = packetType.NONE;
        emptyPkt.legth = packetType.NONE;
        emptyPkt.timeStamp = packetType.NONE;
    end

    pkt = emptyPkt;
%     pkt.type = packetType.NONE;
%     pkt.src = packetType.NONE;
%     pkt.dst = packetType.NONE;
%     pkt.legth = packetType.NONE;
%     pkt.timeStamp = packetType.NONE;
    
end