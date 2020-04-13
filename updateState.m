function [devState, newSimEvents] = updateState(devEve, devState, curTime)
    %updates the state of a device according to the standatd state machine
    %and the device event which happened
    %   gets the device's current state (a struct) and the event which 
    %   caused this invocation, does the needed changes and/or events 
    %   creations and returns the device's new state 
    
    newSimEvents = {};
    eventType = devEve.type;
    handled = 0; % a flag for handling the event, to avoid 'illegal event' error in some cases

    % MED_BUSY and MED_FREE events can happen in every state, so we do the
    % basic handling of them - inc. or dec. medCtr - here.
    % special treatments in special states will be done inside the switch
    if(eventType == devEventType.MED_BUSY)
        devState.medCtr = devState.medCtr + 1;
        handled = 1;  
    elseif(eventType == devEventType.MED_FREE)
        devState.medCtr = devState.medCtr - 1;
        handled = 1;
    end
    % we also have to handle PACKET_EXISTS event here, insert to queue if
    % we are not IDLE
    if(eventType == devEventType.PACKET_EXISTS) 
        if(devState.curState ~= devStateType.IDLE)
            % we have to push the packet to the device's queue
            devState.queue = insertPacketToQueue(devState.queue, devEve.pkt); 
            handled = 1; % only if it's 'IDLE' state we will actually start sensing later
        end
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
                    if(devState.medCtr == 0)
                        devState.curState = devStateType.REC_PACK; % no matter if it's an ACK or a packet
                    else
                        % collision! a packet arrived while the medium is busy!
                        opts = createOpts(devEve.pkt, timerType.NONE);  
                        newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                    end
                
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
            end
                      
        case devStateType.START_CSMA
            
            switch eventType
            
                case devEventType.MED_BUSY
                      devState.curState = devStateType.WAIT_FOR_IDLE;
                      % creare a 'CLEAR_TIMER' event for the DIFS timer which
                      % exists
                      opts = createOpts(emptyPacket(), timerType.DIFS);
                      newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
    
                case devEventType.TIMER_EXPIRED
                    % just for sanity check:
                    if(devEve.timerType == timerType.DIFS)
                        devState.curState = devStateType.TRAN_PACK;
                        opts = createOpts(devState.curPkt, timerType.NONE);  
                        newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt), devState.dev, opts); % TODO: now it does not work, we have to ninsure it works: calculating the transmission time according to the device's provided function
                    elseif(handled == 0)  
                        fprintf('Illegal event') % TODO: handle the error
                    end
                    
            otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
            end
            
        case devStateType.TRAN_PACK
            
            switch eventType
            
                case devEventType.TRAN_END
                 devState.curState = devStateType.WAIT_FOR_ACK;
                 % create a 'SET_TIMER' event for the ACK TO
                 opts = createOpts(devState.curPkt, timerType.ACK);
                 newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.ackTO, devState.dev, opts); 
            
                case devEventType.REC_START
                 % collision!!
                 opts = createOpts(devEve.pkt, timerType.NONE); % the "received" packet is the one which collided
                 newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);            
            
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
             end
                       
        case devStateType.WAIT_FOR_ACK
           
            switch eventType
           
                case devEventType.REC_START 
                    if(devEve.pkt.type == packetType.ACK)
                        % OK, make sense
                        devState.curState = devStateType.REC_ACK;
                    else
                        % assume we cannot receive a packet here
                       if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                       end
                    end

                case devEventType.TIMER_EXPIRED
                    % sanity check
                    if(devEve.timerType == timerType.ACK)
                        % ACK Timeout!!!
                        devState.curCWND = min(devState.curCWND*2, devState.CWmax);
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
                        fprintf('Illegal event') % TODO: handle the error

                    end
                
           otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
            end
            
        case devStateType.REC_ACK
           
            switch eventType
           
                case devEventType.MED_BUSY
                    % collision!!
                    opts = createOpts(devEve.pkt, timerType.NONE); % TODO: insure opts here contains the right packet
                    newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                    devState.curState = devStateType.WAIT_FOR_ACK; % we have to keep waiting
           
                case devEventType.REC_END
                    if(checkACKValidity(devEve.pkt, devState) == 1) 
                      % create a 'CLEAR_TIMER' event for the ACK timer which
                      % exists, because the packet already arrived
                      opts = createOpts(emptyPacket(), timerType.ACK);
                      newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                      % the sent packet was already taken out of the device's queue
                      devState.sucSentBytes = devState.sucSentBytes + devState.curPkt.legth;
                      devState.curPkt = emptyPacket();
                      devState.curRet = 0;
                      % check if we have more packets to send in our queue;
                      % assume the sent packet is not in the queue anymore 
                      if(size(devState.queue, 2)==0)
                        devState.curState = devStateType.IDLE;
                      else
                        % there is another packet to send! immediately start
                        % the sensing process
                        devState.curPkt = getPktFromQueue(devState.queue); % the packet which we have to send
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
                      end
                    end
           
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
             end
     
        case devStateType.WAIT_FOR_IDLE
            
            switch eventType
            
                case devEventType.MED_FREE
                    if(devState.medCtr == 0)
                        % the medium is sensed as free
                        devState.curState = devStateType.WAIT_DIFS;
                        % creare a 'SET_TIMER' event after DIFS time
                        opts = createOpts(emptyPacket(), timerType.DIFS);
                        newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                    end
            
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
            end
            
        case devStateType.WAIT_DIFS
            
            switch eventType
            
                case devEventType.MED_BUSY
                  devState.curState = devStateType.WAIT_FOR_IDLE;
                  % creare a 'CLEAR_TIMER' event for the DIFS timer which
                  % exists
                  opts = createOpts(emptyPacket(), timerType.DIFS);
                  newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
    
                case devEventType.TIMER_EXPIRED
                    % just for sanity check:
                    if(devEve.timerType == timerType.DIFS)
                        devState.curState = devStateType.BACKING_OFF;
                        devState.curBackoff = randomizeBackoff(devState);
                        devState.startBackoffTime = curTime;
                        opts = createOpts(emptyPacket(), timerType.BACKOFF);
                        newSimEvents{1} = createEvent(simEventType.SET_TIMER, devState.curBackoff, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    elseif(handled ==0)  
                        fprintf('Illegal event') % TODO: handle the error
                    end
            
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
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
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt), devState.dev, opts); % TODO: insure it works: calculating the transmission time according to the device's provided function
                    end
            
                case devEventType.MED_BUSY
                    % unfortunately, the medium became busy so update backoff
                    % and wait for idle
                    devState.curState = devStateType.WAIT_FOR_IDLE;
                    devState.curBackoff = devState.curBackoff - (curTime - devState.startBackoffTime); % the remaining time to count
                    devState.startBackoffTime = -1;
 
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end

            end
            
        case devStateType.REC_PACK
            
            switch eventType
            
                case devEventType.MED_BUSY
                    % collision!!
                    opts = createOpts(devEve.pkt, timerType.NONE);  
                    newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
                
                case devEventType.REC_END
                    if(checkPackValidity(devState, packet)) 
                        % valid packet
                        devState.recBytes = devState.recBytes + devEve.pkt.legth; % count the receives packet bytes
                        devState.curState = devStateType.SEND_ACK;
                        opts = createOpts(createACK(devEve.pkt, devState, curTime), timerType.NONE);  
                        newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                        newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.ackDur, devState.dev, opts); % TODO: calculate the ACK Duration 
                    else
                        % not valid packet - throw it 
                        devState.curState = devStateType.IDLE;
                    end
                 
            
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end
            end
            
        case devStateType.SEND_ACK
            
            switch eventType
            
                case devEventType.TRAN_END
                    devState.curState = devStateType.IDLE;
                
                case devEventType.REC_START
                    % collision!!
                    opts = createOpts(devEve.pkt, timerType.NONE); % the "received" packet is the one which collided
                    newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);    
           
                otherwise
                    if (handled == 0) 
                        fprintf('Illegal event') % TODO: handle the error
                    end

            end

           
        otherwise
             fprintf('Invalid device state!') % we should not reach this line...
            
    end
end