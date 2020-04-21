function [PPDU] = pktLengthFunc(MSDU, phyRate)
    %calculates the duration (in seconds) of a given MSDU length
    %   flow: MSDU->MPDU->PSDU->PPDU
    
    % calculate MPDU from MSDU - 34 bytes redundancy:
    MPDU = MSDU + 34;
    % PSDU is actully MPDU:
    PSDU = MPDU;
    % calcuate PPDU from PSDU, assuming 802.11a PHY:
    % first, calculate the number of symbols:
    nSym = 13 + ceil((PSDU*8 +22)/(4*phyRate));
    % finally, each symbol takes 4 microseconds:
    PPDU = nSym*4;
    % convert to seconds:
    PPDU = PPDU*(10^-6);
   
end