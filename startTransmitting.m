function [devState, newSimEvents] = startTransmitting(devState, curTime)
    %starts a packet transmission
    
    newSimEvents =[];
    devState.curState = devStateType.TRAN_PACK;
    devState.curBackoff = -1; % no active backoff
    devState.startBackoffTime = -1; % no active backoff
    opts = createOpts(devState.curPkt, timerType.NONE);
    newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
    newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt.length, devState.curPkt.link.phyRate), devState.dev, opts); % TODO: insure it works: calculating the transmission time according to the device's provided function (the handling works OK, we just have to implement the function)
    
end