
function [SimTime, EffectiveThpt1, EffectiveThpt2, CollPer, PacketsTimeLine] = comSim(NumOfDevs, InterArrival, PacketsToSend, LinksLens, ST, SIFS, AckSize, AckDur, AckTO, NumRet, LinkRate, TranRates, PLossPer, FinishTime)
    
    %Simulates the link, according to the input parameters
    %   Station_ wants to send "packets_" in "tranRate_", the IFS times and 
    %   the CSMA variables are as specified in the input variables.
    %   The function returns the total time of the simulation, the
    %   effective link throughput and the percentage of collided packets.
    %   It also plots some graphs regarding to the transmission times of
    %   the packets.
    
    % packet: a struct which contains its lenght (in bytes), its source 
    % and its destination
    
    fprintf('Simulator started...');
 
    c = 299704644.54; % light speed in air in m/sec
    curTime = 0; % time in simulation, in microseconds
%     TimeA = 0;
%     TimeB = 0;
    DIFS = SIFS + 2*ST; 
    collCnt = 0; % collisions counter
    APD = (LinksLens*1000)/c; % air propagation delay in seconds, a matrix of APDs according to the distances between the devices - APD for devices i and j can be found in cell [i, j] in the array
    rndRange = 100; % the range of random first sending time, in microseconds
    
    % empty queues for the packets the devices want to send
    queues = {};
    eventsList = {};
    eventTimes = {};
    
    % some 1*NumOfPackets control arrays, characterizing the devices' states
    nextSend = ones(1, NumOfDevs);% the next packets to send for each device
    nextGen = ones(1, NumOfDevs); % next packet to generate for each device
    tranTimes = zeros(1, NumOfDevs);
    nRetries = zeros(1, NumOfDevs);
    backoffs = 3000*ones(1, NumOfDevs); % 3000 is an idnication for no backoff
    finTimes = -1*ones(1, NumOfDevs); % the next finish transmitting times of the stations
    backlogged = zeros(1, NumOfDevs); % a control array, 1 stands for a backlogged station 
    waitForIdle = zeros(1, NumOfDevs); % a control array, 1 stands for a defferred station 
    transmit = zeros(1, NumOfDevs); % a control array, 1 stands for a transmitting station 
    ackTimeouts = zeros(1, NumOfDevs); % a times array, which contains the Ack Timeouts of the current transmission for each station
    curTranPkt = {}; % current packet that each device wants to transmit
    curRecPkt = {}; % current packet that each device receives
    
    % event: struct which contains the fields: type, time, station
    % create 'GEN'PACK' event for each station 
    for i=1:NumOfDevs
        pkt = PacketsToSend(i, nextGen(i));
        nextGen(i) = nextGen(i)+1;
        e = createEvent('GEN_PACK', randi(rndRange), i, pkt);
        % insert events to the data structure, which we have to maintain sorted
        % accordding to the 'time' field.
        eventsList{i} = e;
        eventTimes{i} = e.time;
    end
    
    % here the way is keeping a seperate sorted times vector and sorting 
    % the events array according to it...
    [~,TimeSort]=sort(cell2mat(eventTimes)); % Get the sorted order of times
    eventsList = eventsList(TimeSort);
 
    mediumStates = repmat({'idle'},1,NumOfDevs); % the medium state from each station's point of view
    CWmin = 1;
    CWmax = 1023;
    cwnd = 1; % the current contention window (the backoff range)
    
    % run this loop until the simulation time ends or both of the stations
    % finished transmitting
    while((sum(nextSend) < (size(packetsToSend, 1)*size(packetsToSend, 2)))  & (curTime <= FinishTime)) % not everybody finished
        % find the last event happens now
        curTime = eventsList{1}.time;
        i = 1;
        time = curTime;
        while((time == curTime) && (i+1 < size(eventsList, 2)))
            time = eventsList{i+1}.time; % assume there are at least 2 events int the array
            i = i+1;
        end 
        i = i-1; % we increased i one time extra
        currentEvents = eventsList(1:i);
        
        for ind=1:i % foreach event in currentEvents
            event = currentEvents{ind}; % the struct
            station = event.station;
            % handle event
            switch event.type
                
                case 'GEN_PACK'
                    % TODO: stop generating if the array of packets to send
                    % becomes empty
                    queues{station, nextGen(station)} = PacketsToSend(station, nextGen(station));
                    % create new 'GEN_PACKET' event after IAT
                     e = createEvent('GEN_PACK', curTime + InterArrival, station);
                     [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                     if (size(queues{station}, 2) == 1)
                         % this is the only packet in the queue so we
                         % create a 'CSMA_START' event 1 microsecond later
                         e = createEvent('CSMA_START', curTime + 1, station);
                         [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                     end
                     
                case 'CSMA_START'
                    % calculate the transmission time of the packet and
                    % insert it to the corresponding cell in the tranTimes
                    % array
                    curTranPkt{station} = PacketsToSend(station, nextSend(station)); % TODO: take from the queue
                    tranTimes(station) = curTranPkt{station}.lenght/TranRates(station); % TODO: make a function for it, based on the standard
                    if (strcmp(mediumStates{station},'idle')) % strcmp returns true if the strings are identical
                         % the medium is free, so we create a 'PACKET_TRAN'
                         % event after DIFS time
                         e = createEvent('PACKET_TRAN', curTime + DIFS, station);
                         [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    end
                    if(strcmp(mediumStates{station},'busy'))
                         % the medium is busy, so we create a 'DEFER'
                         % event by the end of the current transmission
                         % TODO: figure out a way to know the finish time
                         % of the current transmitting station/s... maybe
                         % max(finTimes).
                         e = createEvent('DEFER', curTime + max(finTimes) + SIFS + APD + AckDur, station); % the other station's finish time, plus the ACKking procedure of this station
                         [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                         % update the control bit for defferring (waiting
                         % for an idle medium)
                         waitForIdle(station) = 1;
                    end
                    
                case 'DEFER'
                    if (strcmp(mediumStates{station},'idle')) % it should be the situation... is it possible that it won't be?
                        % update the control bit for defferring (waiting
                        % for an idle medium)
                        waitForIdle(station) = 0;
                        % create a 'BACKOFF_START' event for this station
                        % after DIFS time
                        e = createEvent('BACKOFF_START', curTime + DIFS, station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order 
                    end
                    
                case 'BACKOFF_START'
                    if(backoffs(station)==3000) % if there is no relevant backoff randomize a new one
                        backoffs(station) = ST*rand(0, cwnd);
                    end
                    % update the control bit for being backlogged 
                    backlogged(station) = 1;
                    % create a 'BACKOFF_DEC' event for each  backlogged 
                    % station within the smallest backoff time 
                    % (the station who chose it might "win")
                    for j=1:NumOfPackets
                        if(backoffs(j)~=3000) % if there is a relevant backoff
                            e = createEvent('BACKOFF_DEC', curTime + min(backoffs), j);
                            [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order 
                        end
                    end
                    
                case 'BACKOFF_DEC'
                    % cnt = 0; % counts the number of stations whose backoffs turns to zero at the moment
                    if(backoffs(station)~=3000) % if there is a relevant backoff
                        backoffs(station) = backoffs(station) - min(backoffs);
                    end
                    if(backoffs(station)==0)
                        % update the control bit for NOT being backlogged 
                        backlogged(station) = 0;
%                             cnt = cnt + 1;
                        % backoff time ended! create a 'PACKET_TRAN'
                        % event 1 microsecind later
                        e = createEvent('PACKET_TRAN', curTime + 1, station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order 
                    end
                  
                    
%                     if(cnt > 1)
%                         % collision occurred! I'm not sure about this
%                         % indication for collision...
%                         mediumStates{station} = 'collison';
%                         collCnt = collCnt + 1; % the packet collided
%                     else % so cnt == 1, so station 3-e.station should stop its backoff
%                         e.type = 'BACKOFF_STOP'; % TODO: think more about it... we also have to delete the 'DEC_BACKOFF' event corresponding to this station!
%                         e.time = curTime + 1;
%                         e.station = 3-e.station;
%                         [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order 
                  
                case 'BACKOFF_STOP'
                    % from now on, the station is waiting for an idle
                    % medium and is not backlogged
                    backlogged(station) = 0;
                    waitForIdle(station) = 1;

%                     % create 'BACKOFF_CONT' after the finish time
%                     e.type = 'DEFER'; 
%                     e.time = finishTime(3-station) + SIFS + APD + AckDur; % I'm not sure about this time...
%                     e.station = station;
%                     [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order 
                
%                 case 'BACKOFF_CONT'
%                     % continue form the same backoff counter value, without
%                     % randomizing a new one
%                     e.type = 'BACKOFF_DEC';
%                     e.time = curTime + min(backoffs);
%                     e.station = min(backoffs); % only in this event, the "station" fiels contains the time we have to decrease from the backoff!!
%                     [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order 
                    
                case 'PACKET_TRAN'
                    transmit(station) = 1;
                    ackTimeouts(station) = curTime + AckTO;
                    % we have to check whether or not a collision occurred
                    % here
                    % in case of COLLISSION:
                    if(strcmp(mediumStates{station}, 'collision')) % in case of collision, both events of transmission will get here when the medium state is 'collision'
                        % create a 'ACK_MISS' event for this station after ACK TO expires
                        e = createEvent('ACK_MISS', curTime + AckTO, station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    else
                        % in case of NO COLLISSION:
                        % create an 'ACK_TRAN' event for the second station
                        % within packet transmisson time + propagation delay
                        e = createEvent('ACK_TRAN', curTime + APD + tranTimes(station) + SIFS, curTranPkt{station}.dst, curTranPkt{station});
                        % wait SIFS before sending the ACK - ctrl packet!
                        % takes us to the other station: 3-2=1; 3-1=2 (we will have to chnge it when we work with more than 2 stations...)
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                    end
                    
                    % anyway, we update the finish transmission time 
                    % (the time when the medium will be free)
                    finTimes(station) = curTime + APD + tranTimes(station);
                    % no need for the current station's backoff anymore:
                    backoffs(station) = 3000; 
                    
                    % and, we create a 'MED_FREE' event within packet 
                    % transmisson time + propagation delay
                    e = createEvent('MED_FREE', finTimes(station), curTranPkt{station}.dst); %  TODO: add such events for the other devices
                    [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                    % create a 'MED_BUSY' event for the other station after
                    % APD - this is the time when the other station starts
                    % to "feel" that the medium is really busy
                    e = createEvent('MED_BUSY', curTime + APD, curTranPkt{station}.dst); %  TODO: add such events for the other devices
                    [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                    % create a 'END_TRAN' event for the this station after
                    % the transmission time 
                    e = createEvent('END_TRAN', curTime + tranTimes(station), station);
                    [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                    if (size(queues{station}, 2) > 1)
                         % there are more packets to send in the queue, so we
                         % create a 'CSMA_START' event 1 microsecond later
                         e = createEvent('CSMA_START', curTime + 1, station);
                         [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                     end

                case 'END_TRAN'
                    transmit(station) = 0;
                    
                case 'ACK_TRAN'
                    % assume no collision will occur now... the sending 
                    % station is waiting for this ACK... 
                    
                    % create a 'ACK_REC' event for the second station
                    % within ackDur + propagation delay
                    curRecPkt{station} = event.packet;
                    e = createEvent('ACK_REC', curTime + APD + AckDur, curRecPkt{station}.src); % TODO: find the ackDur and fix the 'station'... it's for the packet sender...
                    [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                    % create a 'MED_BUSY' event for the other station after
                    % APD - this is the time when the other station starts
                    % to "feel" that the medium is really busy
                    e = createEvent('MED_BUSY', curTime + APD, curTranPkt{station}.dst); %  TODO: add event for the other devices
                    [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                    % create a 'MED_FREE' event within packet transmisson 
                    % time + propagation delay
                    e = createEvent('MED_FREE', curTime + APD + AckDur, curTranPkt{station}.dst); %  TODO: add event for the other devices
                    [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    
                case 'MED_BUSY'
                    % catch the medium (from this station's point of view)
                    mediumStates{station} = 'busy';
                    % triger a 'BACKOFF_STOP' event if the station is
                    % backlogged
                    if(backlogged(station) == 1)
                        e = createEvent('BACKOFF_STOP', curTime + 1, station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                        % check if there exists a future 'DEC_BACKOFF' 
                        % event for this station 
                        decBInd = findEvent(station, 'DEC_BACKOFF', eventsList);
                        if(size(decBInd, 2) ~= 0)
                            % there exist such event, must be only one.
                            % TODO: think if it is neccessary to insure it
                            % delete it!
                            eventsList(decBInd) = [];
                            eventTimes(decBInd) = [];
                        end
                    end
                    if(waitForIdle(station) == 1)
                    % cancel the future 'DEFER' event that should appear 
                    % in the list                
                    defInd = findEvent(station, 'DEFER', eventsList);
                        if(size(decBInd, 2) ~= 0)
                            % there exist such event, must be only one.
                            % TODO: think if it is neccessary to insure it
                            % delete it!
                            eventsList(defInd) = [];
                            eventTimes(defInd) = [];
                        end
                    end
                    
                case 'MED_FREE'
                     % free the medium (from this station's point of view)
                     mediumStates{station} = 'idle'; 
                     % triger a 'DEFER' event if we are waiting for idle
                     if(waitForIdle(station) == 1)
                        e = createEvent('DEFER', curTime + 1, station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                     end
                     
                case 'ACK_MISS'
                    cwnd = min(cwnd*2, CWmax);
                    nRetries(station) = nRetries(station)+1;
                    if (nRetries(station) < NumRet) % we can still try again
                        e = createEvent('CSMA_START',  curTime + 1, station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    else
                        % no more retries, throw packet and zero retries
                        % counter
                        queues{station} = queues{station}(2:nextSend(station));
                        nRetries(station) = 0;
                    end
                    
                case 'ACK_REC'
                    nextSend(station) = nextSend(station)+1;
                    queues{station} = queues{station}(2:nextSend(station)); % removing the successfully sent packet (which is the first in the queue) from the queue
                    nRetries(station) = 0; % zero the numRetries variable for this station, because we are about to start transmitting a new packet
                    ackTimeouts(station) = 0; % this ack timeout is irrelvant from now on
                
                case 'COLLISION'
                    % check wether an 'ACK_MISS' event already
                    % exists, and if not - create one and delete the
                    % 'ACK_REC' event from eventList and eventTimes
                    ackMInd = findEvent(station, 'ACK_MISS', eventsList);
                    if(size(ackMInd, 2) == 0)
                        % if so, there exists an 'ACK_REC' event we should
                        % delete
                        ackRInd = findEvent(station, 'ACK_REC', eventsList);
                        if(size(ackRInd, 2) ~= 0)
                           % we should enter this
                           eventsList(defInd) = [];
                           eventTimes(defInd) = [];
                        end
                        % and create an 'ACK_MISS' event
                        e = createEvent('ACK_MISS', ackTimeouts(station), station);
                        [eventTimes, eventsList]=insertInOrder(eventTimes, eventsList, e.time, e); % insert the new event and its time to the corresponding arrays in the right order
                    end
         
                otherwise
                    fprintf('invalid event!') % we should not reach here...
            end
            
            % delete the whole cells of the handled event anmd its time from the lists
            eventsList(i) = []; 
            eventTimes(i) = [];
                
        end       

    end
    % End of simulation
    % Output calculations:
    SimTime = curTime; % in microseconds
%     EffectiveThpt1 = sum(PacketsToSend(1), "all")/(TimeA*(10^(-6)));
%     EffectiveThpt2 = sum(PacketsToSend(2), "all")/(TimeB*(10^(-6)));
    CollPer = collCnt/(size(PacketsToSend(1), 2)+size(PacketsToSend(2), 2));
end



    