function [packetsDS, packet] = insertPacketToDS(packetsDS, curRet, packet, startTime)
    % inserts a packet time interval to the documentation DS 
    %   writes only its metadata and starting time! other info is unknown
    %   returns the updated DS together with the packet, with its index in
    %   the DS
    if(curRet == 0)
        % create a new packet documentation struct for the packet
        packet.ind = size(packetsDS, 2)+1;
        pd.pkt = packet;
        tran.start = startTime;
        tran.coll = -1; % -1 stands for "we don't know yet or it's irrelevant"
        tran.end = -1;
        tran.reach = -1;
        pd.trans = {};
        pd.trans{curRet+1} = tran;
        % create a new cell in the DS for this new packet documentation
        packetsDS{packet.ind} = pd;
    else
        % a pd for this packet already exists, so just create a new 'tran'
        % struct in the pd.trans array
        tran.start = startTime;
        tran.coll = -1; % -1 stands for "we don't know yet or it's irrelevant"
        tran.end = -1;
        tran.reach = -1;
        packetsDS{packet.ind}.trans{curRet+1} = tran;
    end
    
end