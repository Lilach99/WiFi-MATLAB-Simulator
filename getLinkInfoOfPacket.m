function [linkInd] = getLinkInfoOfPacket(pkt, linksInfoArr)
    %returns the linkInfo (index) of a packet, using the array if it's an
    %ACK packet and the packet itself if its a data packet
     
    switch pkt.type
        case packetType.DATA
            linkInd = pkt.linkInfo;
        case packetType.ACK
            % pkt has no linkInfo field in the struct, so we have to find
            % it in the linkInfo DS
            linkInd = findLinkInfo(pkt.src, pkt.dst, linksInfoArr);
        otherwise
            % error..
            fprintf('illegal packet type');
            linkInd = -1;
    end
    
end