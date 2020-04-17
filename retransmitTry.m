function [devState, newSimEvents] = retransmitTry(devState, curTime)
    %handled a retransmit try in case of an ACK timeout
    newSimEvents=[];
    devState.curCWND = min(devState.curCWND*2, devState.CWmax);
    devState.isWaitingForACK = 0; % the device is not waiting anymore
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
        devState.curState = devStateType.IDLE;
        devState.lostBytes = devState.lostBytes + 1; % save info about the lost packet
    end
    
end