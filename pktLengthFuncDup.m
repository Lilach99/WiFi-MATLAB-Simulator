function [PPDU] = pktLengthFuncDup(MSDU, phyRate)
%calculates the packet length and multipy it by 2, just for sanity checks!
%   Note that this is not the right calculation, it's for special testing!
    
    % calculate MPDU from MSDU - 34 bytes redundancy:
    MPDU = MSDU + 34;
    % PSDU is actully MPDU:
    PSDU = MPDU;
    PPDU = 2*calcMACDur(PSDU, phyRate);
   
end
