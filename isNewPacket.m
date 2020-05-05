function [isNew] = isNewPacket(pktAcked, linksDSCell)
    %checks if the given packet is new, and if so, returns 1
    desInd = find(linksDSCell.recPktsInds == pktAcked.ind);
    if(size(desInd, 2) == 0)
        % we haven't seen this packet yet
        isNew = 1;
    else
        isNew = 0;
    end
   
end

