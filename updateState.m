function [newState, newSimEvents] = updateState(devEve, devState, curTime)
    %updates the state of a device according to the standatd state machine
    %and the device event which happened
    %   gets the device's current state (a struct) and the event which 
    %   caused this invocation, does the needed changes and/or events 
    %   creations and returns the device's new state 
    
    newState = devState; % will be changed as needed later on
    newSimEvents = {};
    eventType = devEve.type;
    handled = 0; % a flag for handling the event, to avoid 'illegal event' error in some cases

    % MED_BUSY and MED_FREE events can happen in every state, so we do the
    % basic handling of them - inc. or dec. medCtr - here.
    % special treatments in special states will be done inside the switch
    if(eventType == devEventType.MED_BUSY)
        newState.medCtr = devState.medCtr + 1;
        handled = 1;  
    elseif(eventType == devEventType.MED_FREE)
        newState.medCtr = devState.medCtr - 1;
        handled = 1;
    end
    % we also have to handle PACKET_EXISTS event here
    if(eventType == devEventType.PACKET_EXISTS) 
        handled = 1; % only if it's 'IDLE' state we will treat later
    end


    switch devState.curState
        
        case devStateType.IDLE
            if(eventType == devEventType.PACKET_EXISTS) 
                newState.curPkt = getPktFromQueue(); % the packet which we have to send, TODO: implement this function
                % there is a packet to send
                if(devState.medCtr == 0) 
                    % medium is free from our point of view
                    newState.curState = devStateType.START_CSMA;
                    % creare a 'SET_TIMER' event after DIFS time
                    opts = createOpts(newState.curPkt, timerType.DIFS);
                    newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                else
                    % medium is busy!
                    newState.curState = devStateType.WAIT_FOR_IDLE;
                end
            
            elseif(eventType == devEventType.REC_START)
                if(devState.medCtr == 0)
                    newState.curState = devStateType.REC_PACK; % TODO: handle the wasBusy for collisions detections - if needed...
                else
                    % collision! a packet arrived while the medium is busy!
                    opts = createOpts(devEve.pkt, timerType.NONE);  
                    newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                end
                
            elseif(handled == 0) 
                fprintf('Illegal event') % TODO: handle the error
            end
                      
        case devStateType.START_CSMA
            if(eventType == devEventType.MED_BUSY)
                newState.curState = devStateType.WAIT_FOR_IDLE;
                  % creare a 'CLEAR_TIMER' event for the DIFS timer which
                  % exists
                  opts = createOpts(emptyPacket(), timerType.DIFS);
                  newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
    
            elseif(eventType == devEventType.TIMER_EXPIRED)
                % just for sanity check:
                if(devEve.timerType == timerType.DIFS)
                    newState.curState = devStateType.TRAN_PACK;
                    opts = createOpts(devState.curPkt, timerType.NONE);  
                    newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt), devState.dev, opts); % TODO: now it does not work, we have to ninsure it works: calculating the transmission time according to the device's provided function
                elseif(handled == 0)  
                    fprintf('Illegal event') % TODO: handle the error
                end
            elseif(handled == 0)  
                fprintf('Illegal event') % TODO: handle the error
            end
            
        case devStateType.TRAN_PACK
             if(eventType == devEventType.TRAN_END)
                 newState.curState = devStateType.WAIT_FOR_ACK;
                 % create a 'SET_TIMER' event for the ACK TO
                 opts = createOpts(devState.curPkt, timerType.ACK);
                  newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.ackTO, devState.dev, opts); 
             elseif(handled == 0)
                fprintf('Illegal event') % TODO: handle the error
             end
                       
        case devStateType.WAIT_FOR_ACK
            if(eventType == devEventType.REC_START)
                newState.curState = devStateType.REC_ACK;
            elseif(eventType == devEventType.TIMER_EXPIRED)
                    % sanity check
                    if(devEve.timerType == timerType.ACK)
                        % ACK Timeout!!!
                        newState.curCWND = min(devState.curCWND*2, devState.CWmax);
                        if(devState.curRet < devState.numRet)
                            % we still have some retries
                            newState.curRet  = devState.curRet + 1;
                            if(devState.medCtr == 0) 
                                % medium is free from our point of view
                                newState.curState = devStateType.START_CSMA;
                                % create a 'SET_TIMER' event after DIFS time
                                opts = createOpts(devState.curPkt, timerType.DIFS);
                                newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                            else
                                % medium is busy!
                                newState.curState = devStateType.WAIT_FOR_IDLE;
                            end
                        else
                            % no more retries!
                            newState.curState = devStateType.IDLE;
                        end
                    elseif(handled ==0)
                        fprintf('Illegal event') % TODO: handle the error

                    end
                
            elseif(handled ==0)
                fprintf('Illegal event') % TODO: handle the error
            end
            
        case devStateType.REC_ACK
            if(eventType == devEventType.MED_BUSY)
                % collision!!
                opts = createOpts(devEve.pkt, timerType.NONE); % TODO: insure opts here contains the right packet
                newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev,opts);
                newState.curState = devStateType.WAIT_FOR_ACK; % we have to keep waiting
            elseif(eventType == devEventType.REC_END)
                if(checkACKValidity(devEve.pkt, devState) == 1) 
                  % create a 'CLEAR_TIMER' event for the ACK timer which
                  % exists, because the packet already arrived
                  opts = createOpts(emptyPacket(), timerType.ACK);
                  newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                  % TODO: insure the simulation takes the successfully sent packet out of the device's queue 
                  newState.sucSentBytes = devState.sucSentBytes + devState.curPkt.legth;
                  newState.curPkt = emptyPacket();
                  newState.curRet = 0;
                  % check if we have more packets to send in our queue;
                  % assume the sent packet is not in the queue anymore 
                  if(size(devState.queue, 2)==0)
                    newState.curState = devStateType.IDLE;
                  else
                    % there is another packet to send! immediately start
                    % the sensing process
                    newState.curPkt = getPktFromQueue(); % the packet which we have to send, TODO: implement this function
                    % there is a packet to send
                    if(devState.medCtr == 0) 
                        % medium is free from our point of view
                        newState.curState = devStateType.START_CSMA;
                        % creare a 'SET_TIMER' event after DIFS time
                        opts = createOpts(newState.curPkt, timerType.DIFS);
                        newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                    else
                        % medium is busy!
                        newState.curState = devStateType.WAIT_FOR_IDLE;
                    end
                  end
                end
            elseif(handled ==0) 
                 fprintf('Illegal event') % TODO: handle the error
             end
     
        case devStateType.WAIT_FOR_IDLE
            if(eventType == devEventType.MED_FREE)
                if(newState.medCtr == 0)
                    % the medium is sensed as free
                    newState.curState = devStateType.WAIT_DIFS;
                    % creare a 'SET_TIMER' event after DIFS time
                    opts = createOpts(emptyPacket(), timerType.DIFS);
                    newSimEvents{1} = createEvent(simEventType.SET_TIMER, curTime + devState.DIFS, devState.dev, opts);
                end
            elseif(handled ==0) 
                fprintf('Illegal event') % TODO: handle the error
            end
            
        case devStateType.WAIT_DIFS
             if(eventType == devEventType.MED_BUSY)
              newState.curState = devStateType.WAIT_FOR_IDLE;
                  % creare a 'CLEAR_TIMER' event for the DIFS timer which
                  % exists
                  opts = createOpts(emptyPacket(), timerType.DIFS);
                  newSimEvents{1} = createEvent(simEventType.CLEAR_TIMER, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
    
             elseif(eventType == devEventType.TIMER_EXPIRED)
                % just for sanity check:
                if(devEve.timerType == timerType.DIFS)
                    newState.curState = devStateType.BACKING_OFF;
                    newState.curBackoff = randomizeBackoff(devState);
                    newState.startBackoffTime = curTime;
                    opts = createOpts(emptyPacket(), timerType.BACKOFF);
                    newSimEvents{1} = createEvent(simEventType.SET_TIMER, newState.curBackoff, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                elseif(handled ==0)  
                    fprintf('Illegal event') % TODO: handle the error
                end
             elseif(handled ==0)
                fprintf('Illegal event') % TODO: handle the error
            end
            
        case devStateType.BACKING_OFF
            if(eventType == devEventType.TIMER_EXPIRED)
                % sanity check
                if(devState.medCtr == 0 && devEve.timerType == timerType.BACKOFF)
                    % medium is free and it's a backoff timer which expired
                    newState.curState = devStateType.TRAN_PACK;
                    newState.curBackoff = -1; % no active backoff
                    newState.startBackoffTime = -1; % no active backoff
                    opts = createOpts(devState.curPkt, timerType.NONE);
                    newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.pktLenFunc(devState.curPkt), devState.dev, opts); % TODO: insure it works: calculating the transmission time according to the device's provided function
                end
            elseif (eventType == devEventType.MED_BUSY)
                % unfortunately, the medium became busy so update backoff
                % and wait for idle
                newState.curState = devStateType.WAIT_FOR_IDLE;
                newState.curBackoff = devState.curBackoff - (curTime - devState.startBackoffTime); % the remaining time to count
                newState.startBackoffTime = -1;

            elseif(handled ==0)
                fprintf('Illegal event') % TODO: handle the error

            end
            
        case devStateType.REC_PACK
            if(eventType == devEventType.MED_BUSY)
                % collision!!
                opts = createOpts(devEve.pkt, timerType.NONE);  
                newSimEvents{1} = createEvent(simEventType.COLL_INC, curTime, devState.dev, opts);
            
            elseif(eventType == devEventType.REC_END)
                if(checkPackValidity(devState, packet)) 
                    % valid packet
                    newState.recBytes = devState.recBytes + devEve.pkt.legth; % count the receives packet bytes
                    newState.curState = devStateType.SEND_ACK;
                    opts = createOpts(createACK(devEve.pkt, devState, curTime), timerType.NONE);  
                    newSimEvents{1} = createEvent(simEventType.TRAN_START, curTime, devState.dev, opts); % note that we have to make the simulation handle this event before increasing the current time !!!!
                    newSimEvents{2} = createEvent(simEventType.TRAN_END, curTime + devState.ackDur, devState.dev, opts); % TODO: calculate the ACK Duration 
                else
                    % not valid packet - throw it
                    newState.curState = devStateType.IDLE;
                end
                 
            elseif(handled ==0)
                fprintf('Illegal event') % TODO: handle the error

            end
            
        case devStateType.SEND_ACK
            if(eventType == devEventType.TRAN_END)
                newState.curState = devStateType.IDLE;
            elseif(handled ==0)
                fprintf('Illegal event') % TODO: handle the error

            end

           
        otherwise
             fprintf('Invalid device state!') % we should not reach this line...
            
    end
end