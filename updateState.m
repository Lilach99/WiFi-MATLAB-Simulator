function [devState, newSimEvents] = updateState(devEve, devState, curTime)
    %updates the state of a device according to the standatd state machine
    %and the device event which happened
    %   gets the device's current state (a struct) and the event which
    %   caused this invocation, does the needed changes and/or events
    %   creations and returns the device's new state
    
%     % for debugging
%     disp(devState.dev);
%     disp(devState.curState);
%     disp(devEve.type);
    
    newSimEvents = {};
    eventType = devEve.type;
    handled = 0; % a flag for handling the event, to avoid 'illegal event' error in some cases
    
    % REC_START and REC_END events can happen in every state, so we do the
    % basic handling of them here, only if they have to be treated as
    % "MED_BUSY and MED_FREE" - inc. or dec. medCtr.
    % special treatments in special states will be done inside the switch
    if((eventType == devEventType.REC_START) && (isPacketMine(devEve.pkt, devState.dev) == 0)) % treat like "MED_BUSY", bacause the packet is NOT destined to this device
        devState.medCtr = devState.medCtr + 1;
        handled = 1;
    elseif((eventType == devEventType.REC_END) && (isPacketMine(devEve.pkt, devState.dev) == 0)) % treat like "MED_FREE", bacause the packet is NOT destined to this device
        devState.medCtr = devState.medCtr - 1;
        handled = 1;
    end
    
    % we also have to handle PACKET_EXISTS event here, insert to queue if
    % we are not IDLE
    if(eventType == devEventType.PACKET_EXISTS)
            % we have to push the packet to the device's queue
            devState.queue = insertPacketToQueue(devState.queue, devEve.pkt);
            handled = 1; % only if it's 'IDLE' state we will actually start sensing later
            % if it is idle - we will take the packet from the queue in the
            % switch
    end
    
    switch devState.curState
        
        case devStateType.IDLE
            
            switch eventType
                
                case devEventType.PACKET_EXISTS
                    [devState.curPkt, devState.queue] = getPktFromQueue(devState.queue); % the packet which we have to send, it is removed from the queue
                    % there is a packet to send
                    if(devState.medCtr == 0)
                        % medium is free from our point of view
                        devState.curState = devStateType.START_CSMA;
                        % creare a 'SET_TIMER' event after DIFS time
                        opts = createOpts(devState.curPkt, timerType.DIFS);
                        newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                    else
                        % medium is busy!
                        devState.curState = devStateType.WAIT_FOR_IDLE;
                    end
                    
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        if(devState.medCtr == 0)
                            devState = updateReceptionState(devState, devEve.pkt);  
                        else
                            % collision! a packet arrived while the medium is busy!
                            opts = createOpts(devEve.pkt, timerType.NONE);
                            newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts); 
                            devState = updateReceptionState(devState, devEve.pkt);  % the device has to receive the packet anyway... he will really know about the collision at the end of reception
                            devState.isColl = devState.isColl + 1; % remembere this packet has been collided

                        end
                    end
                    % if the packet is for other device - don't do nothing,
                    % it has already been treated
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
            end
            
        case devStateType.START_CSMA
            
            switch eventType
                
                case devEventType.REC_START
                        % create a 'CLEAR_TIMER' event for the DIFS timer which
                        % exists
                        opts = createOpts(emptyPacket(), timerType.DIFS);
                        newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    if(isPacketMine(devEve.pkt, devState.dev) == 0) % treat like "MED_BUSY"
                        devState.curState = devStateType.WAIT_FOR_IDLE;
                    else
                        % this is a packet for us! we have to receive it
                        % and continue the transmitting attempt later
                        devState = updateReceptionState(devState, devEve.pkt);  
                        % TODO: insure the handling is OK   
                    end
                    
                case devEventType.TIMER_EXPIRED
                    % just for sanity check:
                    if(devEve.timerType == timerType.DIFS)
                        devState.curState = devStateType.TRAN_PACK;
                        opts = createOpts(devState.curPkt, timerType.NONE);
                        newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt.length, 10), devState.dev, opts); % TODO: now it does not work, we have to ninsure it works: calculating the transmission time according to the device's provided function, 10 is instead of the PHY rate...
                    elseif(handled == 0)
                        fprintf('Illegal event') 
                    end
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event')
                    end
            end
            
        case devStateType.TRAN_PACK
            
            switch eventType
                
                case devEventType.TRAN_END
                    devState.curState = devStateType.WAIT_FOR_ACK; % update the correspnding control bit
                    devState.isWaitingForACK = 0; % the device is not waiting anymore
                    % create a 'SET_TIMER' event for the ACK TO
                    opts = createOpts(devState.curPkt, timerType.ACK);
                    newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.ackTO, devState.dev, opts);
                    
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        % collision!!
                        opts = createOpts(devEve.pkt, timerType.NONE); % the "received" packet is the one which collided
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                        devState.isColl = devState.isColl + 1; % remember the "received" packet was a collided one
                    end
                    % if it's not for this device - do nothing
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
            end
            
        case devStateType.WAIT_FOR_ACK
            
            switch eventType
                
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        if(devEve.pkt.type == packetType.ACK)
                            % OK, make sense
                            devState.curState = devStateType.REC_ACK;
                        else
                            % assume we cannot receive a packet here
                        end
                    end
                    % if it's not for this device - do nothing
                    
                case devEventType.TIMER_EXPIRED
                    % sanity check
                    if(devEve.timerType == timerType.ACK)
                        % ACK Timeout!!!
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
                    elseif(handled ==0)
                        fprintf('Illegal event') 
                        
                    end
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
            end
            
        case devStateType.REC_ACK
            
            switch eventType
                
                case devEventType.REC_START
                    % anyway it's a collision!! no matter if the packet is
                    % for us or not!
                    % if it's the first collision with the received packet,
                    % we have to count it for it , otherwise we had already
                    % counted
                    if(devState.isColl == 0)
                        opts = createOpts(devState.curRecPkt, timerType.NONE); 
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
                        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "original" packet, for the validity check
                    end
                    if(isPacketMine(devEve.pkt) == 1) % we have to count the new packet also as a collided one
                        opts = createOpts(devEve.pkt, timerType.NONE); 
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
                        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "new" packet, for the validity check
                    end
                    % TODO: insure the above mechanism works!!!
                    
                case devEventType.REC_END
                    if(checkACKValidity(devEve.pkt, devState) == 1)
                        devState.isWaitingForACK = 0; % the device is not waiting anymore, the desired ACK arrived
                        % create a 'CLEAR_TIMER' event for the ACK timer which
                        % exists, because the packet already arrived
                        opts = createOpts(emptyPacket(), timerType.ACK);
                        newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                        % the sent packet was already taken out of the device's queue
                        devState.sucSentBytes = devState.sucSentBytes + devState.curPkt.legth;
                        devState.curPkt = emptyPacket();
                        devState.curRet = 0;
                        [devState, newSimEvent, isNew] = handleNextPkt(devState); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew== 1)
                             newSimEvents{2} = newSimEvent; % insert the new event to the array
                        end
                        
                    elseif(devState.isColl > 0)
                        % it is a collided packet so we cannot receive it
                        % properly, but we have to decrease the 'isColl'
                        % counter of the device for future receptions
                        devState.isColl = devState.isColl - 1;
                        [devState, newSimEvent, isNew] = handleNextPkt(devState); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew== 1)
                             newSimEvents{1} = newSimEvent; % insert the new event to the array
                        end
                        
                    elseif(devState.isWaitingForACK == 0)
                        % the device is not waiting for ACK now, it might
                        % be a retransmit attempt, so just ignore the ACK
                        [devState, newSimEvent, isNew] = handleNextPkt(devState); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew== 1)
                             newSimEvents{1} = newSimEvent; % insert the new event to the array
                        end
                        
                    else
                        fprintf('packet did not collide but still not valid');
                    end
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event');
                    end
            end
            
        case devStateType.WAIT_FOR_IDLE
            
            switch eventType
                
                case devEventType.REC_END
                    if(isPacketMine(devEve.pkt, devState.dev) == 0) % check if the packet is not destined to this device, and if so, treat as "MRD_FREE"
                        if(devState.medCtr == 0)
                            % the medium is sensed as free
                            devState.curState = devStateType.WAIT_DIFS;
                            % creare a 'SET_TIMER' event after DIFS time
                            opts = createOpts(emptyPacket(), timerType.DIFS);
                            newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                        end
                    else
                        % this is a packet for us! we have to receive it
                        % and continue the transmitting attempt later
                        devState = updateReceptionState(devState, devEve.pkt);  
                        % TODO: insure the handling is OK  
                    end
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
            end   
            
        case devStateType.WAIT_DIFS
            
            switch eventType
                
                case devEventType.REC_START
                      % create a 'CLEAR_TIMER' event for the DIFS timer which
                      % exists
                      opts = createOpts(emptyPacket(), timerType.DIFS);
                      newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    if(isPacketMine(devEve.pkt, devState.dev) == 0) % treat like "MED_BUSY"
                        devState.curState = devStateType.WAIT_FOR_IDLE;
                    else
                        % this is a packet for us! we have to receive it
                        % and continue the transmitting attempt later
                        devState = updateReceptionState(devState, devEve.pkt);  
                        % TODO: insure the handling is OK  
                    end
                    
                case devEventType.TIMER_EXPIRED
                    % just for sanity check:
                    if(devEve.timerType == timerType.DIFS)
                        devState.curState = devStateType.BACKING_OFF;
                        devState.curBackoff = randomizeBackoff(devState);
                        devState.startBackoffTime = curTime;
                        opts = createOpts(emptyPacket(), timerType.BACKOFF);
                        newSimEvents{1} = createEvent(simEventType.SET_TIMER, devState.curBackoff, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    elseif(handled ==0)
                        fprintf('Illegal event') 
                    end
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
            end
            
        case devStateType.BACKING_OFF
            
            switch eventType
                
                case devEventType.TIMER_EXPIRED
                    % sanity check
                    if(devState.medCtr == 0 && devEve.timerType == timerType.BACKOFF)
                        % medium is free and it's a backoff timer which expired
                        devState.curState = devStateType.TRAN_PACK;
                        devState.curBackoff = -1; % no active backoff
                        devState.startBackoffTime = -1; % no active backoff
                        opts = createOpts(devState.curPkt, timerType.NONE);
                        newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt), devState.dev, opts); % TODO: insure it works: calculating the transmission time according to the device's provided function (the handling works OK, we just have to implement the function)
                    end
                    
                case devEventType.REC_START
                      % create a 'CLEAR_TIMER' event for the BACKOFF timer 
                      % which exists
                      opts = createOpts(emptyPacket(), timerType.BACKOFF);
                      newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                   
                    if(isPacketMine(devEve.pkt, devState.dev) == 0) % treat like "MED_BUSY"
                        % unfortunately, the medium became busy so update backoff
                        % and wait for idle
                        devState.curState = devStateType.WAIT_FOR_IDLE;
                        devState.curBackoff = devState.curBackoff - (curTime - devState.startBackoffTime); % the remaining time to count
                        devState.startBackoffTime = -1;
                    else
                        % this is a packet for us! we have to receive it
                        % and continue the transmitting attempt later
                        devState = updateReceptionState(devState, devEve.pkt);  
                        % TODO: insure the handling is OK  
                    end
                                            
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event')
                    end
                    
            end
            
        case devStateType.REC_PACK
            
            switch eventType
                
                case devEventType.REC_START
                    % anyway it's a collision!! no matter if the packet is
                    % for us or not!
                    % if it's the first collision with the received packet,
                    % we have to count it for it , otherwise we had already
                    % counted
                    if(devState.isColl == 0)
                        opts = createOpts(devState.curRecPkt, timerType.NONE); 
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
                        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "original" packet, for the validity check
                    end
                    if(isPacketMine(devEve.pkt) == 1) % we have to count the new packet also as a collided one
                        opts = createOpts(devEve.pkt, timerType.NONE); 
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
                        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "new" packet, for the validity check
                    end
                    % TODO: insure the above mechanism works!!!
                    
                case devEventType.REC_END
                    if(checkPackValidity(devState, devEve.pkt))
                        % valid packet
                        devState.recBytes = devState.recBytes + devEve.pkt.length; % count the receives packet bytes
                        devState.curState = devStateType.SEND_ACK;
                        opts = createOpts(createACK(devEve.pkt, devState, curTime), timerType.NONE);
                        newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime + devState.SIFS, devState.dev, opts); % start to transmit the ACK after SIFS time; TODO: check if it's OK to change state to SEND_ACK although we actually start to send after SIFS time - in a sense of collsions handing - it should not happen in pTp links...
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.SIFS + devState.ackDur, devState.dev, opts); % TODO: calculate the ACK Duration
                        devState.curRecPkt = emptyPacket(); % collision counter shows 0
                        % we do not have to use handleNextPkt because first
                        % we have to send ACK on the valid received one
                        
                    elseif(devState.isColl > 0)
                        % it is a collided packet so we cannot receive it
                        % properly, but we have to decrease the 'isColl'
                        % counter of the device for future receptions
                        devState.isColl = devState.isColl - 1;
                        [devState, newSimEvent, isNew] = handleNextPkt(devState); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew == 1)
                             newSimEvents{1} = newSimEvent; % insert the new event to the array
                        end
                        
                   else
                        % not valid packet - throw it
                        [devState, newSimEvent, isNew] = handleNextPkt(devState); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew == 1)
                             newSimEvents{1} = newSimEvent; % insert the new event to the array
                        end
                        fprintf('packet did not collide but still not valid');
                    end
    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
            end
            
        case devStateType.SEND_ACK
            
            switch eventType
                
                case devEventType.TRAN_END
                    % handle the next packet to send, if exists
                    [devState, newSimEvent, isNew] = handleNextPkt(devState); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                    if(isNew == 1)
                         newSimEvents{1} = newSimEvent; % insert the new event to the array
                    end
                    
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        % collision!!
                        opts = createOpts(devEve.pkt, timerType.NONE); % the "received" packet is the one which collided
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                        devState.isColl = devState.isColl + 1; % remember the "received" packet is collided
                    end
                    % if it's not for the device - do nothing
                    
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event') 
                    end
                    
            end
            
            
        otherwise
            fprintf('Invalid device state!') % we should not reach this line...
            
    end
end