function [linkI] = createlinkInfo(src, dst, phyRate, dataRate, minPS, maxPS, pktDropoffRate)
    %craetes an instance of linkInfo struct, according to the input
    %parameters
    linkI.src = src;
    linkI.dst = dst;
    linkI.phyRate = phyRate * 1000000;
    linkI.dataRate = dataRate * 1000000;
    linkI.maxPS = maxPS;
    linkI.minPS = minPS;
    linkI.pktDropoffRate = pktDropoffRate; 
    
end