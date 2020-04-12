function [isValid] = checkACKValidity(packet, devState)
    %checks wether a packet is a valid ack packet
    %   gets the packet and the current device's state and insures:
    %   is the packet destined to this device?
    %   is the packet an ACK packet?
        
    if(packet.type == packetType.ACK && packet.dest == devState.dev)
        isValid = 1;
    else
        isValid = 0;
    end
    
end