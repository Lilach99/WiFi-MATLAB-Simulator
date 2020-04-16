function [isValid] = checkPackValidity(devState, packet)
    %checks wether the input packet is valid
    %   insures:
    %   is the packet destined to the device?
    %   is it a data packet?
    %   is this a packet which did not collided?
    
    if(packet.dst == devState.dev && packet.type == packetType.DATA && devState.isColl == 0)
        isValid = 1;
    else
        isValid = 0;
    end
    
end