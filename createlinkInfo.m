function [linkI] = createlinkInfo(src, dst, phyRate, dataRate, minPS, maxPS, pktDropoffRate, pktPolicy)
    %craetes an instance of linkInfo struct, according to the input
    %parameters
    linkI.src = src;
    linkI.dst = dst;
    linkI.phyRate = phyRate * (10^6); % the multiplication stands for te M
    linkI.dataRate = dataRate * (10^6); % the multiplication stands for te M
    linkI.maxPS = maxPS;
    linkI.minPS = minPS;
    linkI.pktDropoffRate = pktDropoffRate; 
    linkI.pktPolicy = pktPolicy;
    
end