function [] = insertPacketToOutSD(packetsOutDS, curPkt, curTime)
    %inserts the needed info. about a packet to the packets outputDS
    packetsOutDS.size = packetsOutDS.size + 1;
    i = packetsOutDS.size;
    packetsOutDS.inds(i) = curPkt.ind;
    packetsOutDS.srcs(i) = curPkt.src;
    packetsOutDS.dsts(i) = curPkt.dst;
    packetsOutDS.startTimes(i) = curTime;
    packetsOutDS.durations(i) = pktLengthFunc(curPkt.length, 6*10^6);

end

