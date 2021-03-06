function [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime, isBackoffMandatory)
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
            devState = changeDevState(devState, devStateType.WAIT_DIFS); % TODO: insure it has to be WAIT_DIFS state... to continue backoff or start a new one
            % creare a 'SET_TIMER' event after DIFS time
            opts = createOpts(devState.curPkt, timerType.DIFS);
            newSimEvent = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
            isNew = 1;
        else
            % medium is busy!
             devState = changeDevState(devState, devStateType.WAIT_FOR_IDLE);        
        end
        
    elseif(devState.queue.tail == 1)
        % we are not trying to send a packet now and our queue is empty
        devState = changeDevState(devState, devStateType.IDLE);
        devState.curPkt = emptyPacket();
        
    else
        % there is another packet to send! immediately start
        % the sensing process
        [devState.curPkt, devState.queue] = getPktFromQueue(devState.queue); % the packet which we have to send
        % disp(['queue size of dev ',int2str(devState.dev),'is: ', int2str(devState.queue.tail),' curCWND is:',int2str(devState.curCWND)]);
        
         % there is a packet to send
        if(devState.medCtr == 0)
            % medium is free from our point of view, we have to change state
            % to WAIT_DIFS if it is the end of a successful transmission,
            % and to START_CSMA otherwise
            if(isBackoffMandatory ==1)
                devState = changeDevState(devState, devStateType.WAIT_DIFS); % it has to be WAIT_DIFS state... because we must excecute a new backoff process
            else
                devState = changeDevState(devState, devStateType.START_CSMA); % it has to be START_CSMA otherwise
            end
            % creare a 'SET_TIMER' event after DIFS time - we need it
            % anyway
            opts = createOpts(devState.curPkt, timerType.DIFS);
            newSimEvent = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
            isNew = 1;
        else
            % medium is busy!
            devState = changeDevState(devState, devStateType.WAIT_FOR_IDLE);        
        end
    end
    devState.curRecPkt = emptyPacket();
    
end