function [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime)
    %handle the next packet to send, if exists
    %   check if we have more packets to send in our queue; assume the sent 
    %   packet is not in the queue anymore
    %   if there are packets in the queue, start its transmitting attempt
    
    newSimEvent = [];
    isNew = 0;
    if(devState.curPkt.type ~= packetType.NONE)
        % there is a non-empty current packet, so we have to continue
        % transmitting it (we stopped a carrier sensing procedure to
        % receive a packt so we have to continue the procedure)
        if(devState.medCtr == 0)
            % medium is free from our point of view
            devState.curState = devStateType.WAIT_DIFS; % TODO: insure it has to be WAIT_DIFS state... to continue backoff or start a new one
            % creare a 'SET_TIMER' event after DIFS time
            opts = createOpts(devState.curPkt, timerType.DIFS);
            newSimEvent = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
            isNew = 1;
        else
            % medium is busy!
            devState.curState = devStateType.WAIT_FOR_IDLE;
        end
        
    elseif(size(devState.queue, 2) == 0)
        % we are not trying to send a packet now and our queue is empty
        devState.curState = devStateType.IDLE;
        devState.curPkt = emptyPkt();
        
    else
        % there is another packet to send! immediately start
        % the sensing process
        devState.curPkt = getPktFromQueue(devState.queue); % the packet which we have to send
        % there is a packet to send
        if(devState.medCtr == 0)
            % medium is free from our point of view
            devState.curState = devStateType.WAIT_DIFS; % TODO: check if it has to be this state or WAIT_DISF state... to continue backoff or start a new one
            % creare a 'SET_TIMER' event after DIFS time
            opts = createOpts(devState.curPkt, timerType.DIFS);
            newSimEvent = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
            isNew = 1;
        else
            % medium is busy!
            devState.curState = devStateType.WAIT_FOR_IDLE;
        end
    end
    devState.curRecPkt = emptyPacket();
    
end