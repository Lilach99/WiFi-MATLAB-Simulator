function [devP] = createDevParams(dev, SIFS, ST, numRet, ACKLenFunc, ackTO, pktLenFunc)
    %craetes an instance of devParams struct, according to the input
    %parameters
    devP.dev = dev;
    devP.SIFS = SIFS * (10^-6);
    devP.ST = ST * (10^-6);
    devP.numRet = numRet;
    devP.ackLenFunc = ACKLenFunc;
    devP.ackTO = ackTO * (10^-6);
    devP.pktLenFunc = pktLenFunc;

end