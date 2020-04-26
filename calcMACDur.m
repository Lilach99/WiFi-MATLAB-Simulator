function [PPDU] = calcMACDur(PSDU, phyRate)
    %calculates the PPDU from the given PSDU
    
    % calcuate PPDU from PSDU, assuming 802.11a PHY:
    % first, calculate the number of symbols:
    nSym = 13 + ceil((PSDU*8 + 22)/(4*(phyRate*10^-6))); % assume phtRate is given in Mbps
    PPDU = nSym*4*(10^-6); % finally, each symbol takes 4 microseconds
    
end