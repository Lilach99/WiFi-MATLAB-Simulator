function [devState, newSimEvents] = retransmitTry(devState, curTime)
    %handled a retransmit try in case of an ACK timeout
    % disp('ACK TO occurred!');
    
    newSimEvents=createEvent(simEventType.SET_TIMER, 0, 0); % init!!!
    newSimEvents(1) = []; 
    
    %disp(int2str(devState.SSRC));
    if(devState.curRet > 0)
        % we have to increase CW only after unsuccessful REtransmission!
        devState.curCWND = increaseCWND(devState.curCWND, devState.CWmax, devState.backoffTech);
    end
    devState.isWaitingForACK = 0; % the device is not waiting anymore
    devState.isACKToExp = 0;
    if(devState.curRet < devState.numRet)
        % we still have some retries
        devState.curRet  = devState.curRet + 1;
        devState.SSRC = devState.SSRC + 1;
        if(devState.medCtr == 0)
            % medium is free from our point of view, but we must excecute a
            % new backoff procedure because it was an unsuccessful transmission
            devState = changeDevState(devState, devStateType.WAIT_DIFS);
            % create a 'SET_TIMER' event after DIFS time
            opts = createOpts(devState.curPkt, timerType.DIFS);
            newSimEvents(1) = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
        else
            % medium is busy!
            devState = changeDevState(devState, devStateType.WAIT_FOR_IDLE);
        end
    else
        % no more retries!
        devState.lostBytes = devState.lostBytes + devState.curPkt.length; % save info about the lost packet
        devState.curPkt = emptyPacket(); % then delete it, we do not want to send it again...
        devState.curRet = 0;
        [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime, 1); % maybe we have more packets to send, so we handle it, backoff is mandatory
        if(isNew == 1)
             newSimEvents(1) = newSimEvent; % insert the new event to the array
        end
        if(devState.SSRC == devState.numRet)
            % in this case we have to decrease curCWND 
            devState.curCWND = decreaseCWND(devState.curCWND, devState.CWmin, devState.backoffTech);
        end
    
    end
    
end