function [devP] = createDevParams(dev, SIFS, ST, numRet, ackDur, ackTO, pktLenFunc)
    %craetes an instance of devParams struct, according to the input
    %parameters
    devP.dev = dev;
    devP.SIFS = SIFS;
    devP.ST = ST;
    devP.numRet = numRet;
    devP.ackDur = ackDur;
    devP.ackTO = ackTO;
    devP.pktLenFunc = pktLenFunc;

end