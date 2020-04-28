function [devState, newSimEvents] = retransmitTry(devState, curTime)
    %handled a retransmit try in case of an ACK timeout
    newSimEvents=[];
    devState.curCWND = min(devState.curCWND*2, devState.CWmax);
    devState.isWaitingForACK = 0; % the device is not waiting anymore
    devState.isACKToExp = 0;
    if(devState.curRet < devState.numRet)
        % we still have some retries
        devState.curRet  = devState.curRet + 1;
        if(devState.medCtr == 0)
            % medium is free from our point of view
            devState.curState = devStateType.START_CSMA;
            % create a 'SET_TIMER' event after DIFS time
            opts = createOpts(devState.curPkt, timerType.DIFS);
            newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
        else
            % medium is busy!
            devState.curState = devStateType.WAIT_FOR_IDLE;
        end
    else
        % no more retries!
        devState.lostBytes = devState.lostBytes + devState.curPkt.length; % save info about the lost packet
        devState.curPkt = emptyPacket(); % then delete it, we do not want to send it again...
        [devState, newSimEvents, isNew] = handleNextPkt(devState, curTime); % maybe we have more packets to send, so we handle it
        devState.curRet = 0;
                
    end
    
end