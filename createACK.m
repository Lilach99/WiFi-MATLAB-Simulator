function [ACKpkt] = createACK(packet, devState, timeStamp)
    %gets a packet and prepares an ACK packet on it
    %   ACK size is 14 bytes always
    
    ACKpkt.type = packetType.ACK;
    ACKpkt.src = devState.dev;
    ACKpkt.dst = packet.src;
    ACKpkt.length = 14; % in bytes
    ACKpkt.timeStamp = timeStamp;
    ACKpkt.packetInd = packet.ind;

end