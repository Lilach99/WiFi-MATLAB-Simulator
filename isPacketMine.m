function [isMine] = isPacketMine(pkt, dev, linksInfo)
    %checks if a packet which arrived to a device is really destined to it
    %   compares the pkt.dst with the dev ID
    
    if(pkt.linkInfo.dst == dev)
        isMine = 1;
    else
        isMine = 0;
    end

end