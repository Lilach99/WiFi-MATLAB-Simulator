function [PPDU] = ackLengthFunc(phyRate)
    %calculates the duration (in seconds) of a an ACK packet
    %   PSDU = 14 Bytes, always (according to standard)
    
    PSDU = 14;
    % calcuate PPDU from PSDU, assuming 802.11a PHY:
    % first, calculate the number of symbols:
    nSym = 13 + ceil((PSDU*8 +22)/(4*phyRate));
    % finally, each symbol takes 4 microseconds:
    PPDU = nSym*4;
    % convert to seconds:
    PPDU = PPDU*(10^-6);
    
end