function [compressedPacketsDS] = compressPacketsDS(packetsDS)
    %creates a compressed version of the given packetsDS data structure
    
    dsInd = 1;
    for i=1:size(packetsDS, 2)  
        pktTrans = packetsDS{i}.trans;
        transSize = size(pktTrans, 2);
        for j=1:transSize
            compressedPacketsDS.ind(dsInd) = packetsDS{i}.pkt.ind;
            compressedPacketsDS.src(dsInd) = packetsDS{i}.pkt.src;
            compressedPacketsDS.dst(dsInd) = packetsDS{i}.pkt.dst;
            compressedPacketsDS.startTimes(dsInd) = pktTrans{j}.start;
            compressedPacketsDS.endTimes(dsInd) = pktTrans{j}.end;
            compressedPacketsDS.isAcked(dsInd) = 0;
            dsInd = dsInd + 1;
        end     
        if(packetsDS{i}.isAcked == 1)
            compressedPacketsDS.isAcked(dsInd-1) = 1; % we got a valid ACK only on the last retransmission!
        end
    end
        
end

