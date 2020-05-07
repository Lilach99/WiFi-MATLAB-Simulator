function [devState, newSimEvents] = handleCollidedReception(devState, devEve, curTime)
    %handles a collided packet reception, which happend during another
    %packet reception 
    
    newSimEvents = createEvent(simEventType.COLL_INC, 0, 0); % just init
    newSimEvents(1) = [];
    
    eveInd = 1;
    % if it's the first collision with the current received 
    % packet, we have to count it, otherwise we had already
    % counted it
    if(devState.isColl == 0)
        opts = createOpts(devState.curRecPkt, timerType.NONE); 
        newSimEvents(eveInd) = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
        eveInd = eveInd + 1;
        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "original" packet, for the validity check
    end
    if(isPacketMine(devEve.pkt, devState.dev) == 1) % we have to count the "new packet" also as a collided one
        opts = createOpts(devEve.pkt, timerType.NONE); 
        newSimEvents(eveInd) = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "new" packet, for the validity check
        % here we also have to handle as 'MED_BUSY'
        devState.medCtr = devState.medCtr + 1;
    end
    % if the packet is not for us - we had already updated
    % the medium state as needed
    
end