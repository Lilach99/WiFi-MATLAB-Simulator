function [packetsDS] = modifyPacketReachInDS(packetsDS, curRet, packet, reachTime)
    % changes the packet arrival time (start) in its interval in the 
    % documentation DS returns the updated DS
    
    % a pd for this packet already exists, so just modify the needed 'tran'
    % struct in the pd.trans array
    
    packetsDS{packet.ind}.trans{curRet+1}.reach = reachTime;
    
end