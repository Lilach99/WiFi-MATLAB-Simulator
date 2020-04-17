function [isValid] = checkACKValidity(packet, devState)
    %checks wether a packet is a valid ack packet
    %   gets the packet and the current device's state and insures:
    %   is the packet destined to this device?
    %   is the packet an ACK packet?
    %   is this a packet which did not collided?
    %   is the device waiting for ACK now? if not, it should ignore the packet
    
    if(packet.type == packetType.ACK && packet.dst == devState.dev && devState.isColl == 0 && devState.isWaitingForACK == 1)
        isValid = 1;
    else
        isValid = 0;
    end
    
end