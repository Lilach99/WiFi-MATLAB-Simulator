function [packetsDS] = modifyPacketCollInDS(packetsDS, curRet, packet, collTime)
    % changes the packet collision time in its interval in the documentation DS 
    %   writes only its collision time
    %   returns the updated DS
    
    % a pd for this packet already exists, so just modify the needed 'tran'
    % struct in the pd.trans array
    packetsDS{packet.ind}.trans{curRet+1}.coll = collTime;
    
end