function [PPDU] = ackLengthFunc(phyRate)
    %calculates the duration (in seconds) of a an ACK packet
    %   PSDU = 14 Bytes, always (according to standard)
    
    PSDU = 14;
    PPDU = calcMACDur(PSDU, phyRate);
    
end