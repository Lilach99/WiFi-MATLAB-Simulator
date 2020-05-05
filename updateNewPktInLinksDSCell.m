function [linksDSCell] = updateNewPktInLinksDSCell(linksDSCell, pktAcked)
    %gets a received packet on which we are now sending ACK, and updates that
    %we have received it in the given linksDSCell
    %   the recognition of the packet is done by its "ind" unique field
    linksDSCell.recPktsInds = [linksDSCell.recPktsInds, pktAcked.ind]; % notify that we received this packet
    linksDSCell.dataRecNeto = linksDSCell.dataRecNeto + pktAcked.length; % count this successfully received packet
end

