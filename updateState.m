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
    illegalFlag = 0;
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
    elseif((eventType == devEventType.REC_END) && (isPacketMine(devEve.pkt, devState.dev) == 1) && (devState.isColl > 1))
        % "end of reception" of a collided packet for us, not the original we started to receive, treat as 'MED_FREE' 
        devState.medCtr = devState.medCtr - 1;
        devState.isColl = devState.isColl - 1;
        handled = 1;
    elseif((eventType == devEventType.TIMER_EXPIRED) && (devEve.timerType == timerType.ACK) && (devState.isWaitingForACK == 1))
        % ACK timeout! can happen in any state, so update the relevant parameters
        devState.isWaitingForACK = 0;
        devState.isACKToExp = 1;
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
                            % OK, receive the packet
                            devState = updateReceptionState(devState, devEve.pkt);  
                        else
                            % collision! a packet arrived while the medium is busy!
                            opts = createOpts(devEve.pkt, timerType.NONE);
                            newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts); 
                            % now handle the event as 'MED_BUSY' event
                            devState.medCtr = devState.medCtr + 1;
                            devState.isColl = devState.isColl + 1; % remember this collision to free the medium by the "end of reception" (REC_END event)
                        end
                    end
                    % if the packet is for other device - do nothing,
                    % it has already been treated
                    
                case devEventType.REC_END
                if((isPacketMine(devEve.pkt, devState.dev) == 1) && (devState.isColl > 0) && handled == 0)
                    % "end of reception" of a collided packet for us, not the original we started to receive, treat as 'MED_FREE' 
                    devState.medCtr = devState.medCtr - 1;
                    devState.isColl = devState.isColl - 1;
                end
                
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
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
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt.length, devState.curPkt.link.phyRate), devState.dev, opts); % TODO: now it does not work, we have to ninsure it works: calculating the transmission time according to the device's provided function, 10 is instead of the PHY rate...
                    elseif(handled == 0)
                        illegalFlag = 1;
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
                    devState.isWaitingForACK = 1; % the device is waiting for ack from now on
                    % create a 'SET_TIMER' event for the ACK TO
                    opts = createOpts(devState.curPkt, timerType.ACK);
                    newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.ackTO, devState.dev, opts);
                    
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        % collision!!
                        opts = createOpts(devEve.pkt, timerType.NONE); % the "received" packet is the one which collided
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                        % this is a collided packet, we cannot receive it
                        % properly, so treat as 'MED_BUSY' 
                        devState.medCtr = devState.medCtr + 1;
                        devState.isColl = devState.isColl + 1; % remember the "received" packet was a collided one, for future handling of its 'END_REC' event
                    end
                    % if it's not for this device - do nothing
                    
                case devEventType.REC_END
                    % might happen, if we started to "receive" a collided 
                    % packet during transmitting
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        if(devState.isColl == 1)
                            % treat as MED_FREE
                            devState.medCtr = devState.medCtr - 1;
                            devState.isColl = devState.isColl - 1;
                        end
                    end
                    
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
                    end
            end
            
        case devStateType.WAIT_FOR_ACK
            
            switch eventType
                
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        if(devState.medCtr == 0)
                            % OK, receive the packet
                            devState = updateReceptionState(devState, devEve.pkt);
                            % note that if it's a data packet, we have to 
                            % receive it, and afterwards return to this 
                            % state if the ACK timer did not expired yet
                        else
                            % collision! a packet arrived while the medium is busy!
                            opts = createOpts(devEve.pkt, timerType.NONE);
                            newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts); 
                            % now handle the event as 'MED_BUSY' event
                            devState.medCtr = devState.medCtr + 1;
                            devState.isColl = devState.isColl + 1; % remember this collision to free the medium by the "end of reception" (REC_END event)
                        end
                          
                    end
                    % if it's not for this device - do nothing
                     
                case devEventType.REC_END
                    if((isPacketMine(devEve.pkt, devState.dev) == 1) && (devState.isColl > 0) && handled == 0)
                        % "end of reception" of a collided packet for us, not the original we started to receive, treat as 'MED_FREE' 
                        devState.medCtr = devState.medCtr - 1;
                        devState.isColl = devState.isColl - 1;
                    end
                    
                case devEventType.TIMER_EXPIRED
                    % sanity check
                    if(devEve.timerType == timerType.ACK)
                        % ACK Timeout!!!
                        [devState, newSimEvents] = retransmitTry(devState, curTime);
                    elseif(handled == 0)
                        illegalFlag = 1;
                    end
                    
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
                    end
            end
                    
        case devStateType.REC_PACK
            
            switch eventType
                
                case devEventType.REC_START
                    % anyway it's a collision!! no matter if the packet is
                    % for us or not!
                    [devState, newSimEvents] = handleCollidedReception(devState, devEve, curTime);
                    
                case devEventType.REC_END
                    if(checkPackValidity(devState, devEve.pkt))
                        % valid packet
                        devState.recBytes = devState.recBytes + devEve.pkt.length; % count the receives packet bytes
                        devState.curState = devStateType.SEND_ACK;
                        % devState.curPkt = createACK(devEve.pkt, devState, curTime);
                        opts = createOpts(createACK(devEve.pkt, devState, curTime), timerType.NONE);
                        newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime + devState.SIFS, devState.dev, opts); % start to transmit the ACK after SIFS time; TODO: check if it's OK to change state to SEND_ACK although we actually start to send after SIFS time - in a sense of collsions handing - it should not happen in pTp links...
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.SIFS + devState.ackLenFunc(devEve.pkt.link.phyRate), devState.dev, opts); % TODO: check if we have to take min(pkt.link.rate, opposite link rate)... and if so - how??
                        devState.curRecPkt = emptyPacket(); % collision counter shows 0
                        % we do not have to use handleNextPkt because first
                        % we have to send ACK on the valid received one
                        
                    elseif(devState.isColl > 0)
                        % it is a collided packet so we cannot receive it
                        % properly, but we have to decrease the 'isColl'
                        % counter of the device for future receptions
                        devState.isColl = devState.isColl - 1;
                        [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew == 1)
                             newSimEvents{1} = newSimEvent; % insert the new event to the array
                        end
                        % take care of ACK waiting
                        if(devState.isWaitingForACK == 1)
                            if(devState.isACKToExp == 0)
                                devState.curState = devStateType.WAIT_FOR_ACK;
                            else
                                % ACK TO had already expired!
                                % start a new sending attempt, if it's possible
                                % ACK Timeout!!!
                                [devState, newSimEvents] = retransmitTry(devState, curTime);
                            end
                        end
                        
                   else
                        % not valid packet - throw it
                        [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew == 1)
                             newSimEvents{1} = newSimEvent; % insert the new event to the array
                        end
                        % take care of ACK waiting
                        if(devState.isWaitingForACK == 1)
                            if(devState.isACKToExp == 0)
                                devState.curState = devStateType.WAIT_FOR_ACK;
                            else
                                % ACK TO had already expired!
                                % start a new sending attempt, if it's possible
                                % ACK Timeout!!!
                                [devState, newSimEvents] = retransmitTry(devState, curTime);
                            end
                        end
                        fprintf('packet did not collide but still not valid');
                    end
    
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
                    end
            end
            
        case devStateType.REC_ACK
            
            switch eventType
                
%                 case devEventType.TIMER_EXPIRED
%                     % the ACK timeout expired during an ACK reception, so
%                     % we have to wait until the end of reception, and than
%                     % if the ACK is valid - continue and otherwise -
%                     % retransmit (if we have more retries)
%                     if(devEve.timerType == timerType.ACK)
%                         % sanity check
%                         devState.isACKToExp = 1; 
%                     else
%                         fprintf('illegal timer expired event!');
%                     end
                
                case devEventType.REC_START
                    % anyway it's a collision!! no matter if the packet is
                    % for us or not!
                    [devState, newSimEvents] = handleCollidedReception(devState, devEve, curTime);

                case devEventType.REC_END
                    if(checkACKValidity(devEve.pkt, devState) == 1)
                        devState.isWaitingForACK = 0; % the device is not waiting anymore, the desired ACK arrived
                        newEveInd = 1;
                        if(devState.isACKToExp == 0)
                            % create a 'CLEAR_TIMER' event for the ACK timer which
                            % exists, because the packet already arrived
                            opts = createOpts(emptyPacket(), timerType.ACK);
                            newSimEvents{newEveInd} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                            newEveInd = newEveInd + 1;
                        else
                            % the TIMER_EXPIRED event had already happened
                            % during reception, so we do not have to clear
                            % the corresponding timer
                            devState.isACKToExp = 0; % for the next time
                            opts = createOpts(emptyPacket(), timerType.ACK);
                            newSimEvents{newEveInd} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                            newEveInd = newEveInd + 1;
                        end
                        % the sent packet was already taken out of the device's queue
                        devState.sucSentBytes = devState.sucSentBytes + devState.curPkt.length;
                        devState.curPkt = emptyPacket();
                        devState.curRet = 0;
                        devState.curCWND = devState.CWmin; % reset cwnd to the minimum
                        [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                        if(isNew== 1)
                             newSimEvents{newEveInd} = newSimEvent; % insert the new event to the array
                        end
                        
                    elseif(devState.isColl > 0)
                        % it is a collided packet so we cannot receive it
                        % properly, but we have to decrease the 'isColl'
                        % counter of the device for future receptions
                        devState.isColl = devState.isColl - 1;
                        if(devState.isWaitingForACK == 1)
                            if(devState.isACKToExp == 0)
                                devState.curState = devStateType.WAIT_FOR_ACK;
                            else
                                % ACK TO had already expired!
                                % start a new sending attempt, if it's possible
                                % ACK Timeout!!!
                                [devState, newSimEvents] = retransmitTry(devState, curTime);
                            end
                        else
                            % the device is not waiting for an ACK at all
                             [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                            if(isNew== 1)
                                 newSimEvents{1} = newSimEvent; % insert the new event to the array
                            end
                        end

                    elseif(devState.isWaitingForACK == 0)
                        % the device is not waiting for ACK now, it might
                        % be a retransmit attempt, so just ignore the ACK
                        [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
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
                        % if it is not collided
                        if(devState.isColl > 0 && handled == 0)
                             devState.isColl = devState.isColl - 1; 
                            % here we also have to handle as 'MED_FREE'
                            devState.medCtr = devState.medCtr - 1;
                        elseif(devState.isColl == 0)
                            fprintf("it could be that a non-collided packet for us will end during WAIT_FOR_ACK");
                        end
                        
                    end

               case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % we have to count the "new packet" also as a collided one, beacuse the medium is busy now - we're waiting for idle
                        opts = createOpts(devEve.pkt, timerType.NONE); 
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
                        devState.isColl = devState.isColl + 1; % we have to remember this collision at the end of reception of the "new" packet, for the validity check
                        % here we also have to handle as 'MED_BUSY'
                        devState.medCtr = devState.medCtr + 1;
                    end
                     
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
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
                        newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.curBackoff, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    elseif(handled ==0)
                        illegalFlag = 1;
                    end
                    
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
                    end
            end
            
        case devStateType.BACKING_OFF
            
            switch eventType
                
                case devEventType.TIMER_EXPIRED
                    % sanity check
                    if(devEve.timerType == timerType.BACKOFF)
                        if(devState.medCtr == 0)
                            % medium is free and it's a backoff timer which expired
                            [devState, newSimEvents] = startTransmitting(devState, curTime);
                        else
                            % medium is busy! we have to wait for idle
                            % again!
                            devState.curState = devStateType.WAIT_FOR_IDLE;
                            devState.curBackoff = -1; % no active backoff
                            devState.startBackoffTime = -1; % no active backoff
                        end
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
                        
                        devState.curBackoff = devState.curBackoff - curTime + devState.startBackoffTime; % the remaining time to count
%                         if(devState.curBackoff == 0)
%                             % backoff counter just zerod, so we have to
%                             % start transmitting even it can cause a
%                             % collision! TODO: insure...
%                             [devState, newSimEvents] = startTransmitting(devState, curTime);
%                         end
                        devState.startBackoffTime = -1;
                    else
                        % this is a packet for us! we have to receive it
                        % and continue the transmitting attempt later
                       
                        devState.curBackoff = devState.curBackoff - curTime + devState.startBackoffTime; % the remaining time to count
                        devState.startBackoffTime = -1;
%                         if(devState.curBackoff == 0)
%                             % backoff counter just zerod, so we have to
%                             % start transmitting even it can cause a
%                             % collision! TODO: insure...
%                             [devState, newSimEvents] = startTransmitting(devState, curTime);
%                             devState.isColl =  devState.isColl + 1; % the received packet is collided with the current transmitted packet
%                         else
                        devState = updateReceptionState(devState, devEve.pkt);  
                        % TODO: insure the handling is OK  
%                         end
                    end
                                            
                otherwise
                    if (handled == 0)
                        fprintf('Illegal event')
                    end
                    
            end
            
        case devStateType.SEND_ACK
            
            switch eventType
                
                case devEventType.TRAN_END
                    % take care of ACK waiting, if exists
                        if(devState.isWaitingForACK == 1)
                            if(devState.isACKToExp == 0)
                                devState.curState = devStateType.WAIT_FOR_ACK;
                            else
                                % ACK TO had already expired!
                                % start a new sending attempt, if it's possible
                                % ACK Timeout!!!
                                [devState, newSimEvents] = retransmitTry(devState, curTime);
                            end
                        else
                            % handle the next packet to send, if exists
                            [devState, newSimEvent, isNew] = handleNextPkt(devState, curTime); % checks if there are more packets in the device's queue or state (current packet) and if so, handles it according to the protocol 
                            if(isNew == 1)
                                 newSimEvents{1} = newSimEvent; % insert the new event to the array
                            end
                        end
                        
                case devEventType.REC_START
                    if(isPacketMine(devEve.pkt, devState.dev) == 1) % check if the packet is destined to this device
                        % collision!!
                        opts = createOpts(devEve.pkt, timerType.NONE); % the "received" packet is the one which collided
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                        % this is a collided packet, we cannot receive it
                        % properly, so treat as 'MED_BUSY' 
                        devState.medCtr = devState.medCtr + 1;
                        devState.isColl = devState.isColl + 1; % remember the "received" packet was a collided one, for future handling of its 'END_REC' event
                    end
                    % if it's not for the device - do nothing
                    
                otherwise
                    if (handled == 0)
                        illegalFlag = 1;
                    end
            end
            
        otherwise
            fprintf('Invalid device state!') % we should not reach this line...
            
    end
    
    % for debugging
    if (illegalFlag == 1)
        disp(devState.dev);
        disp(devState.curState);
        disp(devEve);
    end
        
end