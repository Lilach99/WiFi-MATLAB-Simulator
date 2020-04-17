function [packetsDS] = modifyPacketEndInDS(packetsDS, curRet, packet, endTime)
    % changes the packet transmission time end in its interval in the 
    % documentation DS returns the updated DS
    
    % a pd for this packet already exists, so just modify the needed 'tran'
    % struct in the pd.trans array
    packetsDS{packet.ind}.trans{curRet + 1}.end = endTime;
    
end