function [devP] = createDevParams(dev, SIFS, ST, numRet, aggFactor, backoffTech, ACKLenFunc, pktLenFunc)
    %craetes an instance of devParams struct, according to the input
    %parameters
    devP.dev = dev;
    devP.SIFS = SIFS;
    devP.ST = ST;
    devP.numRet = numRet;
    devP.aggFactor = aggFactor;
    devP.backoffTech = backoffTech;
    devP.ackLenFunc = ACKLenFunc;
    devP.pktLenFunc = pktLenFunc;

end