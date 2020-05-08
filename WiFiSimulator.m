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
    linkLens = phyNetParams.linksLens;
    finTime = simulationParams.finishTime;
    debMode = simulationParams.debugMode;
    linksInfo = logNetParams.linksInfo;
    numLinks = size(linksInfo, 2);

    %SIFS = cell2mat((cellfun(@(s)s.SIFS, devsParams,'uni',0)));
    %SlotTime = cell2mat((cellfun(@(s)s.ST, devsParams,'uni',0)));
    %DIFS = SIFS + 2*SlotTime; 

    c = 299704644.54; % light speed in air in m/sec, CONSTANT
    curTime = 0; % time in simulation, in microseconds
    APD = (linkLens*1000)/c; % air propagation delay in seconds, a matrix of APDs according to the distances between the devices - APD for devices i and j can be found in cell [i, j] in the array
    rndRange = 10^-3; % the range of random first sending time, in seconds, TODO: check how to choose it
    % nextSend = ones(1, numDevs);
    
    % empty queues for the packets the devices want to send
    devStates = cell(1, numDevs);
    % create the devices' states cell array
    for i=1:numDevs
        % ACK Timeout = 2 * Air Propagation Time (max) + SIFS + Time to transmit 14 byte ACK frame 
        ackTO = 3*max(APD(i, :)) + devsParams{i}.SIFS + devsParams{i}.ackLenFunc(6*10^6); % according to the minimum PHY rate
        devStates{i} = createDevInitState(devsParams{i}, ackTO);
    end
    
    setGlobaleventInd(0); % initiate the global variable eventInd
    % create the initial simEventType.START_SIM event for the simulation
    simEventsList = createEvent(simEventType.START_SIM, curTime, 0); % station number '0' stands for a global event, which does not relate to a specific station
        
    % output preperations:
    packetsDS = {}; % packets documentation DS
    collCnt = 0; % collisions counter
    linksDS = initialLinksDS(numLinks, linksInfo);
    eventsDS = simEventsList; % just init, useful in Debug mode, events documentation DS, maybe it's better not to pre-allocate...    
    eventsCnt = 1;
    
    % run this loop until the simulation time ends or both of the stations
    % finished transmitting
    while(curTime <= finTime) 
        % find the last simEvent happens now
        if(size(simEventsList, 2)~=0) % we sould start handling only if there are events in the list...
            curTime = simEventsList(1).time;
            i = findLastCurEvent(simEventsList, curTime); % finds the last event in the list that happens now
            [curSimEvents, ~] = sortByHandlingOrder(simEventsList(1:i)); % sorts the events according to their handling order
            while(size(curSimEvents, 2) > 0) % foreach simEvent in currentsimEvents, new events might be added to this list during the handling the original events
                
                simEvent = curSimEvents(1); % the struct
                eventInd = findEvent(curSimEvents(1).id, curSimEvents(1).station, simEventsList); % get the index of the event in the list, using it's event unique ID
                % to catch bugs:
                if(simEventsList(eventInd).type ~= curSimEvents(1).type)
                    listHandlingBug = MException('MyComponent:noSuchVariable', 'different events deleted! error!');
                    throw(listHandlingBug);
                end
                % delete the whole cells of the currently handled simEvent from the lists
                simEventsList(eventInd) = []; 
                curSimEvents(1) = [];

                if(simEvent.time < 0)
                    fprintf('negative time!!!!!');
                end
                
                if(debMode == 1)
                    disp(simEvent.type);
                    disp(simEvent.station);
                    disp(simEvent.time);
                    disp(simEvent.pkt.type);
                end
                % add the simEvent to the events documentation DS if the system
                % is in Debug mode
                
                eventsDS(eventsCnt) = simEvent;
                eventsCnt = eventsCnt + 1;
                
                
                curStation = simEvent.station;
                % handle simEvent
                switch simEvent.type
                   
                    % event handling scheme:
                        % handle current event
                        % update device's state if there's a need
                        % insert new events to the DS
                        % handle  new current-time events if exists
                        
                    case simEventType.START_SIM
                        % create 'GEN'PACK' simEvent to start with for each
                        % link, not each station!
%                         genEvents = cell(1, numLinks);
                        genEve = createEvent(simEventType.GEN_PACK, randi(10)*rndRange, 1);
                        for l=1:numLinks
                            pktTime = randi(10)*rndRange;
                            % create and insert simEvents to the data structure, 
                            % which we maintain sorted accordding to the 'time' field.
                            genEve = createEvent(simEventType.GEN_PACK, pktTime, l);
                            genEvents(l) = genEve;
                        end
                        simEventsList = saveNewEvents(genEvents, simEventsList);
                        curSimEvents = updateEventsList(genEvents, curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
                       
                    case simEventType.END_SIM
                        % make the outputs ready to be returned
                        output.packetsDS = packetsDS; 
                        output.collCnt = collCnt;
                        output.finTime = curTime;
                        output.linksRes = linksDS;
                        
                        output.eventsDS = eventsDS;
                       
                        
                    case simEventType.GEN_PACK
                        % happens per link, triggers a 'NEW_PACKET'
                        % event for the src device of the link (which is
                        % directional)
                        % so, in the 'station' field of the GEN_PACK event,
                        % there will be the link index in the array instead
                        % of a single station's ID.
                        pktLength = randi([linksInfo{curStation}.minPS, linksInfo{curStation}.maxPS]); % randomize the packet size
                        pkt = generatePacket(curStation, linksInfo{curStation}, pktLength , curTime, linksInfo{curStation}.src, linksInfo{curStation}.dst);
                        % update the device that it has a packet to send
                        linksDS{curStation}.generatedPktCnt = linksDS{curStation}.generatedPktCnt + 1;
                        genDevEve = createEvent(devEventType.NEW_PACKET, curTime, linksInfo{curStation}.src, createOpts(pkt, timerType.NONE)); 
                        [devStates{linksInfo{curStation}.src}, newSimEvents] = updateState(genDevEve, devStates{linksInfo{curStation}.src}, curTime);
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                        curSimEvents = updateEventsList(newSimEvents, curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
                        % create a future GEN_PACK simulation event
                        genSimEve = createEvent(simEventType.GEN_PACK, curTime + interArr(pkt, linksInfo{curStation}), curStation); 
                        simEventsList = insertInOrder(simEventsList, genSimEve);
                                            
%                     case simEventType.MED_BUSY
%                         % the medium became busy from some station's point of
%                         % view, so we have to notify this station
%                         medEve = createEvent(devEventType.MED_BUSY, curTime, curStation);
%                         [devStates{curStation}, newSimEvents] = updateState(medEve, devStates{curStation}, curTime);
%                         % insert the new events that the device might triggered 
%                         % to the simEvents list
%                         simEventsList = saveNewEvents(newSimEvents, simEventsList);
%                         curSimEvents = updateEventsList(newSimEvents, curTime); % insert new events which have to be handled right now to the current events list                        
                       
%                     case simEventType.MED_FREE
%                         % the medium became free from some station's point of
%                         % view, so we have to notify this station
%                         medEve = createEvent(devEventType.MED_FREE, curTime, curStation);
%                         [devStates{curStation}, newSimEvents] = updateState(medEve, devStates{curStation}, curTime);
%                         % insert the new events that the device might triggered 
%                         % to the simEvents list
%                         simEventsList = saveNewEvents(newSimEvents, simEventsList);
%                         curSimEvents = updateEventsList(newSimEvents, curTime); % insert new events which have to be handled right now to the current events list
                    
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
                        curSimEvents = updateEventsList(newSimEvents, curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
    
                    case simEventType.CLEAR_TIMER
                        % cancel a timer setting which was done by the device
                        % in the past (if exists), by finding it in the 
                        % simEvents array - assuming there is only ONE timer
                        % event per station!
                        timerSimInd = findTimer(curStation, simEvent.timerType, simEventsList);
                        % delete the whole cells of the SET_TIMER simEvent
                        if(simEventsList(timerSimInd).time == curTime)
                            % we have to delete a timer which is schuduled
                            % to now !!! so we have to delete it from curSimEvents!
                            timerCurInd = findTimer(curStation, simEvent.timerType, curSimEvents);
                            curSimEvents(timerCurInd) = [];
                        end
                        simEventsList(timerSimInd) = [];
                        
                    case simEventType.TRAN_START 
                        curPkt = simEvent.pkt; % 'opts' exists in this case, and it contains the packet which is being transmitted right now
                        %disp(curPkt.type);
                        curRet = devStates{curStation}.curRet;
                        if(curPkt.type ~= packetType.ACK)
                            % insert the packet to the packets DS if it's
                            % not an ACK packet
                            [packetsDS, curPkt] = insertPacketToDS(packetsDS, curRet, curPkt, curTime);
                            devStates{curStation}.curPkt = curPkt; % same packet but with the updated index in the packetsDS!
                        end
                        if(curPkt.type == packetType.ACK)
                            % we are transmitting an ACK packet, what means
                            % we received a packet properly, so if it's the
                            % first time we are receiving it (according to
                            % the "packetInd" filed in the ACK pakcet) - we
                            % have to count its length to the "dataRecNeto"
                            % field in the corrsponding linksDS cell!
                            pktAcked = packetsDS{curPkt.packetInd}.pkt;
                            if(isNewPacket(pktAcked, linksDS{pktAcked.linkInfo}) == 1)
                                linksDS{pktAcked.linkInfo} = updateNewPktInLinksDSCell(linksDS{pktAcked.linkInfo}, pktAcked);
                            end
                        end
                        % create a REC_START event for all devices but the src
                        % of the packet
                        opts = createOpts(curPkt, simEvent.timerType);
%                         newSimEvents = cell(1, numDevs-1); % everyone but the src needs a new event
                        newSimEvents = createEvent(simEventType.REC_START, 0, 0); % just for init
                        newInd = 1;
                        for k=1:numDevs
                            if(k~=curPkt.src)
                                % the src does not receive the packet...
                                newSimEvents(newInd) = createEvent(simEventType.REC_START, curTime + APD(curPkt.src, k), k, opts);
                                newInd = newInd + 1;
                            end
                        end
                        % insert the new events to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                        curSimEvents =updateEventsList(newSimEvents, curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
    
                    case simEventType.TRAN_END
                        curPkt = simEvent.pkt;
                        % update the packet info in the packets DS
                        if(curPkt.type ~= packetType.ACK)
                            curRet = devStates{curStation}.curRet;
                            curPkt = devStates{curStation}.curPkt; % for the ind in the DS...
                            packetsDS = modifyPacketEndInDS(packetsDS, curRet, curPkt, curTime);
                        end
                        desLinkInd = getLinkInfoOfPacket(curPkt, linksInfo);
                        linksDS{desLinkInd} = updateLinkDSCell(devStates{curStation}, linksDS{desLinkInd}, curPkt, simEventType.TRAN_END); % update meta data in the linksDS
                        % create a REC_END event for all devices but the src
                        % of the packet
                        opts = createOpts(curPkt, simEvent.timerType);
%                         newSimEvents = cell(1, numDevs-1); % everyone but the src needs a new event
                        newSimEvents = createEvent(simEventType.REC_START, 0, 0); % just for init
                        newInd = 1;
                        for k=1:numDevs
                            if(k~=curPkt.src)
                                % the src does not receive the packet...
                                newSimEvents(newInd) = createEvent(simEventType.REC_END, curTime + APD(curPkt.src, k), k, opts);
                                newInd = newInd + 1;
                            end
                        end
                        % also, create devEventType.TRAN_END event for the src device
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        tranEve = createEvent(devEventType.TRAN_END, curTime, curStation, opts);
                        [devStates{curStation}, moreNewSimEvents] = updateState(tranEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents([newSimEvents, moreNewSimEvents], simEventsList);
                        curSimEvents =updateEventsList([newSimEvents, moreNewSimEvents], curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
                                            
                    case simEventType.REC_START
                        % save packet info. to the documentation DS
                        curPkt = simEvent.pkt; % 'opts' should exists (with a packet) 
                        curRet = devStates{curPkt.src}.curRet;
                        if(curPkt.type ~= packetType.ACK && curPkt.dst == curStation)
                            % we have to insert the packet meta data to the
                            % DS iff it's a data packet destined for us
                            packetsDS = modifyPacketReachInDS(packetsDS, curRet, curPkt, curTime);
                        end
                        % update the needed device's state
                        opts = createOpts(simEvent.pkt, simEvent.timerType);
                        recStartEve = createEvent(devEventType.REC_START, curTime, curStation, opts);
                        [devStates{curStation}, newSimEvents] = updateState(recStartEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                        curSimEvents =updateEventsList(newSimEvents, curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
                     
                    case simEventType.REC_END
                        curPkt = simEvent.pkt;
                        if(curPkt.dst == simEvent.station)
                            % this is a packet for us so we have to update
                            % its details in the linksInfo DS
                            desLinkInd = getLinkInfoOfPacket(curPkt, linksInfo);
                            linksDS{desLinkInd} = updateLinkDSCell(devStates{curStation}, linksDS{desLinkInd}, curPkt, simEventType.REC_END); % update meta data in the linksDS
                        end
                        opts = createOpts(curPkt, simEvent.timerType);
                        recEndEve = createEvent(devEventType.REC_END, curTime, curStation, opts);
                        [devStates{curStation}, newSimEvents] = updateState(recEndEve, devStates{curStation}, curTime);
                        % insert the new events that the device might triggered 
                        % to the simEvents list
                        simEventsList = saveNewEvents(newSimEvents, simEventsList);
                        curSimEvents =updateEventsList(newSimEvents, curTime, curSimEvents); % insert new events which have to be handled right now to the current events list
                                     
                    case simEventType.COLL_INC
                        % increase the collisions counter by 1
                        collCnt = collCnt + 1;
                        % save packet info to the documentation DS
                        curPkt = simEvent.pkt; % should exists
                        curRet = devStates{curPkt.src}.curRet; % the curRet of the source device is the relevant (assumming ackTO is big enough)
                        if(curPkt.type ~= packetType.ACK && curPkt.dst == curStation)
                            % we have to insert the packet meta data to the
                            % DS iff it's a data packet destined for us
                            packetsDS = modifyPacketCollInDS(packetsDS, curRet, curPkt, curTime);
                        end
                        if(curPkt.dst == simEvent.station)
                            % this is a packet for us so we have to update
                            % its details in the linksInfo DS 
                             desLinkInd = getLinkInfoOfPacket(curPkt, linksInfo);
                             linksDS{desLinkInd} = updateLinkDSCell(devStates{curStation}, linksDS{desLinkInd}, curPkt, simEventType.COLL_INC); % update meta data in the linksDS
                        end
                        
                    otherwise
                        fprintf('invalid simEvent!') % we should not reach this line...
                end
                
                
            end       
            
        end
    end
    % pewpare output if we finished on time
    if(curTime > finTime)
        output.packetsDS = packetsDS; 
        output.collCnt = collCnt;
        output.finTime = finTime;
        output.linksRes = linksDS;
        output.eventsDS = eventsDS;
    end
end
