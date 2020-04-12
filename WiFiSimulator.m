function [output] = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams)
    
    %Simulates the link, according to the linkParams struct fields
    %   the CSMA variables are as specified in the standardParams struct fields.
    %   The function returns the total time of the simulation, the
    %   effective link throughput and the percentage of collided packet,
    %  and also a DS contains information about the packets transmission times.
  
    
    % pkt: a struct which contains its lenght (in bytes), its source 
    % and its destination and its type (control/data)
    
     % simEvent: struct which contains the fields: type, time, station
     
     % link is one directional in the DSs, from src to dst
    
    fprintf('Simulator started...');
 
    % take params from the structs:
    numDevs = phyNetParams.numDevs;
   % linksInfo = logNetParams.conParamsList;
       % numLinks =  size(linksInfo, 2);
    linkLens = phyNetParams.linksLens;
    finTime = simulationParams.finishTime;
    debMode = simulationParams.debugMode;
    linksInfo = logNetParams.linksInfo;
    
    %SIFS = cell2mat((cellfun(@(s)s.SIFS, devsParams,'uni',0)));
    %SlotTime = cell2mat((cellfun(@(s)s.ST, devsParams,'uni',0)));
    %DIFS = SIFS + 2*SlotTime; 

    c = 299704644.54; % light speed in air in m/sec, CONSTANT
    curTime = 0; % time in simulation, in microseconds
    APD = (linkLens*1000)/c; % air propagation delay in seconds, a matrix of APDs according to the distances between the devices - APD for devices i and j can be found in cell [i, j] in the array
    rndRange = 100; % the range of random first sending time, in microseconds
    % nextSend = ones(1, numDevs);
    
    % empty queues for the packets the devices want to send
    queues = cell(100, numDevs); % TODO: insure - 100 cells in a packet queue should be enough? and TODO: we have to implement this queues DS functions and the queue managment!
    simEventsList = {};
    devStates = cell(1, numDevs);
    % create the devices' states cell array
    for i=1:numDevs
        devStates{i} = createDevInitState(devsParams{i}, i);
    end

    % create the initial simEventType.START_SIM event for the simulation
    simEventsList{1} = createEvent(simEventType.START_SIM, curTime, 0); % station number '0' stands for a global event, which does not relate to a specific station
    
    % TODO: calculate the inter arrival time from the rates for each link
    % TODO: handle quques managment !
    % TODO: increase the time somehow when there are no events, to avoid an
    % infinite loop...
    
    % output preperations:
    packetsDS = {}; % packets documentation DS
    collCnt = 0; % collisions counter
    eventsDS = cell(1, 1000); % useful in Debug mode, events documentation DS, maybe it's better not to pre-allocate...    
    eventsCnt = 0;
    
    % run this loop until the simulation time ends or both of the stations
    % finished transmitting
    while(curTime <= finTime) 
        % find the last simEvent happens now
        if(size(simEventsList, 2)~=0) % we sould start handling only if there are events in the list...
            curTime = simEventsList{1}.time;
            i = 1;
            time = curTime;
            while((time == curTime) && (i <= size(simEventsList, 2)))
                time = simEventsList{i}.time; % assume there are at least 2 simEvents int the array
                i = i+1;
            end 
            i = i-1; % we increased i one time extra
            currentsimEvents = simEventsList(1:i);
            disp(currentsimEvents);
            for ind=1:i % foreach simEvent in currentsimEvents
                
                simEvent = currentsimEvents{ind}; % the struct
                % add the simEvent to the events documentation DS if the system
                % is in Debug mode
                if(debMode == 1)
                    eventsDS{eventsCnt} = simEvent;
                    eventsCnt = eventsCnt +1;
                end
                
                curStation = simEvent.station;
                % handle simEvent
                switch simEvent.type
                   
                    % handling scheme:
                        % handle current event
                        % update device's state if there's a need
                        % insert new events to the DS
                        % handle current-time events which were created right
                        % now (by the device)
                        
                    case simEventType.START_SIM
                        % TODO: create the packets queues for each link - not
                        % sure how...
                        % and then create 'GEN'PACK' simEvent to start with for each station 
    %                         for i=1:numDevs
    %                             pkt = generatePacket()
    %                             nextGen(i) = nextGen(i)+1;
    %                             e = createEvent(simEventType.GEN_PACK, randi(rndRange), i, pkt);
    %                             % insert simEvents to the data structure, which we have to maintain sorted
    %                             % accordding to the 'time' field.
    %                             simEventsList{i} = e;
    %                         end
                        
                    case simEventType.END_SIM
                        % make the outputs ready to be returned
                        output.packetsDS = packetsDS; 
                        output.collCnt = collCnt;
                        output.finTime = curTime;
                        if(debMode ==1)
                            output.eventsDS = eventsDS;
                        end
                        
                    case simEventType.GEN_PACK
                        % assume only point to point links, so in the links
                        % info. structs array, we have the only link the
                        % device belongs info.
                        pktLengh = randi([linksInfo{curStation}.minPktSize, linksInfo{curStation}.maxPktSize]); % randomize the packet size
                        pkt = generatePkt(linksInfo{curStation}, pktLengh, curTime, curStation, linksInfo{curStation}.dst);
                        devStates{curStation} = insertPacketToQueue(pkt, devStates{curStation}); % TODO: implement this function! 
                        % update the device that it has a packet to send
                        genDevEve = createEvent(devEventType.PACKET_EXISTS, curTime, curStation); 
                        [devStates{curStation}, newSimEvents] = updateState(genDevEve, devStates{curStation}, curTime);
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                        % create a future GEN_PACK simulation event
                        genSimEve = createEvent(simEventType.GEN_PACK, curTime + interArr(pkt, linksInfo{curStation}), curStation); % TODO: implement this function! 
                        simEventsList = insertInOrder(simEventsList, genSimEve);
                        
                    case simEventType.PACKET_IN_QUQUE
                   
                    case simEventType.CHECK_QUEUE
                                            
                    case simEventType.MED_BUSY
                        % the medium became busy from some station's point of
                        % view, so we have to notify this station
                        medEve = createEvent(devEventType.MED_BUSY, curTime, curStation);
                        [devStates{curStation}, newSimEvents] = updateState(medEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                       
                    case simEventType.MED_FREE
                        % the medium became free from some station's point of
                        % view, so we have to notify this station
                        medEve = createEvent(devEventType.MED_FREE, curTime, curStation);
                        [devStates{curStation}, newSimEvents] = updateState(medEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                    
                    case simEventType.SET_TIMER
                        % notify the device that the timer he asked for had
                        % expired right now, there are 'opts' in a simEventType.SET_TIMER
                        % simEvent
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        timerEve = createEvent(devEventType.TIMER_EXPIRED, curTime, curStation, opts);
                        [devStates{curStation}, newSimEvents] = updateState(timerEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
    
                    case simEventType.CLEAR_TIMER
                        % cancel a timer setting which was done by the device
                        % in the past (if exists), by finding it in the 
                        % simEvents array - assuming there is only ONE timer
                        % event per station!
                        timerInd = findEvent(curStation, simEventType.SET_TIMER, simEventsList);
                        % delete the whole cells of the SET_TIMER simEvent
                        simEventsList(timerInd) = [];
    
                    case simEventType.TRAN_START 
                        curPkt = simEvent.pkt; % 'opts' exists in this case, and it contains the packet which is being transmitted right now
                        curRet = devStates{curStation}.curRet;
                        % insert the packet to the packets DS
                        [packetsDS, curPkt] = insertPacketToDS(packetsDS, curRet, curPkt, curTime);
    
                        pos = 2; % for insertion to the newSimEvent later on
                        % create a recive event for the destination station 
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        recStartEve = createEvent(simEventType.REC_START, curTime + APD(curPkt.src, curPkt.dst), curPkt.dst, opts);
                        newSimEvents = cell(1, numDevs-1); % everyone but the src needs a new event
                        newSimEvents{1} = recStartEve;
                        % create a MED_BUSY event for all devices but the src
                        % and dst of the packet
                        for k=1:numDevs
                            if(k~=curPkt.src && k~=curPkt.dst)
                                % the src and dst are handled differently
                                newSimEvents{pos} = createEvent(simEventType.MED_BUSY, curTime + APD(curPkt.src, k), k, curPkt);
                                pos = pos + 1;
                            end
                        end
                        % insert the new events to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
    
                    case simEventType.TRAN_END
                        curPkt = simEvent.pkt; % 'opts' exists in this case, and it contains the packet which is being transmitted right now
                        curRet = devStates{curStation}.curRet;
                        % update the packet info in the packets DS
                        packetsDS = modifyPacketEndInDS(packetsDS, curRet, curPkt, curTime);
                        
                        pos = 2; % for insertion to the newSimEvent later on
                        % create a recive event for the destination station 
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        recEndEve = createEvent(simEventType.REC_END, curTime + APD(curPkt.src, curPkt.dst), curPkt.dst, opts);
                        newSimEvents = cell(1, numDevs-1); % everyone but the src needs a new event
                        newSimEvents{1} = recEndEve;
                        % create a MED_BUSY event for all devices but the src
                        % and dst of the packet
                        for k=1:numDevs
                            if(k~=curPkt.src && k~=curPkt.dst)
                                % the src and dst are handled differently
                                newSimEvents{pos} = createEvent(simEventType.MED_FREE, curTime + APD(curPkt.src, k), k, curPkt);
                                pos = pos + 1;
                            end
                        end
                        % insert the new events to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList); 
                        
                        % also, create simEventType.TRAN_END event for the src device
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        tranEve = createEvent(devEventType.TRAN_END, curTime, curStation, opts);
                        [devStates{curStation}, newSimEvents] = updateState(tranEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                                            
                    case simEventType.REC_START
                        % save packet info. to the documentation DS
                        curPkt = simEvent.pkt; % 'opts' should exists (with a packet) 
                        curRet = devStates{curStation}.curRet;
                        packetsDS = modifyPacketReachInDS(packetsDS, curRet, curPkt, curTime);
                        % update the needed device's state
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        recStartEve = createEvent(devEventType.REC_START, curTime, curStation, opts);
                        [devStates{curStation}, newSimEvents] = updateState(recStartEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                     
                    case simEventType.REC_END
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        recEndEve = createEvent(devEventType.REC_END, curTime, curStation, opts);
                        [devStates{curStation}, newSimEvents] = updateState(recEndEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                                     
                    case simEventType.COLL_INC
                        % increase the collisions counter by 1
                        collCnt = collCnt +1;
                        % save packet info to the documentation DS
                        curPkt = simEvent.pkt; % should exists
                        curRet = devStates{curStation}.curRet;
                        % update the packet info in the packets DS
                        packetsDS = modifyPacketCollInDS(packetsDS, curRet, curPkt, curTime);
                        
                    case simEventType.LOG_WRITE
                        % TODO: write the event info to some file
             
                    otherwise
                        fprintf('invalid simEvent!') % we should not reach this line...
                end
                
                % delete the whole cells of the handled simEvent from the lists
                simEventsList(i) = []; 
                    
            end       
        end
    end
end



    