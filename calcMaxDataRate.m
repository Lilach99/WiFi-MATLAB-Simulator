function [maxRates] = calcMaxDataRate(pktLength, linkLens, phyRate, slotTimeFactor)
    %calculates the maximal data rates (total, for both sides)
    %according to the link length
    %   The formula: (pktLength*8)/(pktDur + 2APD + DIFS + SIFS + ACKdur)
    %   DIFS = 2*SlotTime + SIFS, 8 is for bytes to bit conversion, 
    %   backoff = 0, ackLength = 14B, linkLen is in kms!
    c = 299704644.54;
    APD = (linkLens*1000)/c;
    numDists = size(linkLens, 2);
    switch slotTimeFactor
        case -1
            % standard
            slotTime = (9*10^-6)*ones(1, numDists);
        otherwise
            slotTime = slotTimeFactor*APD;
    end
            
    SIFS = (16*10^-6)*ones(1, numDists);
    DIFS = SIFS + 2*slotTime;
    numBitsTran = (pktLength*8)*ones(1, numDists);
    pktDur = pktLengthFunc(pktLength, phyRate)*ones(1, numDists);
    ackDur = ackLengthFunc(phyRate)*ones(1, numDists);
    maxRates = numBitsTran ./(pktDur + 2*APD + DIFS + SIFS + ackDur);
    maxRates = maxRates/10e5;
    
end

