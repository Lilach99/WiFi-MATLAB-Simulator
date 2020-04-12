function [isValid] = checkPackValidity(devState, packet)
    %checks wether the input packet is valid
    %   insures:
    %   is the packet destined to the device?
    %   is it a data packet?
    %   maybe also collisions?? or it's already handled? TODO: check it!!!
    if(packet.dst == devState.dev && packet.type == packetType.DATA)
        isValid = 1;
    else
        isValid = 0;
    end
end