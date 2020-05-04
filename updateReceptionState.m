function [devState] = updateReceptionState(devState, pkt)
    %update the device's state according to the packer type
    
    switch pkt.type
        case packetType.DATA
            devState = changeDevState(devState, devStateType.REC_PACK); % if it's a DATA packet
            devState.curRecPkt = pkt;
        case packetType.ACK
            devState = changeDevState(devState, devStateType.REC_ACK); % if it's an ACK packet
            devState.curRecPkt = pkt;
        otherwise
            fprintf('error - empty packet was transmitted!')
    end
    
end