function [PPDU] = pktLengthFunc(MSDU, phyRate)
    %calculates the duration (in seconds) of a given MSDU length
    %   flow: MSDU->MPDU->PSDU->PPDU
    
    % calculate MPDU from MSDU - 34 bytes redundancy:
    MPDU = MSDU + 34;
    % PSDU is actully MPDU:
    PSDU = MPDU;
    PPDU = calcMACDur(PSDU, phyRate);
   
end