function [event] = createEvent(type, time, station, opts)
    % creates an event as specifed and returns it
    %  the 'packet' parameter is optional, there are events which does not
    %  relates to a specific packet...
%     
%     global eventInd; % event index, will be unique for each event
%     if(type == simEventType.START_SIM)
%         eventInd = 0; % it's the first event, so initiate eventInd
%     end
    
    event.type = type;
    event.time = time;
    event.station = station;
    event.pkt = emptyPacket();
    event.timerType = timerType.NONE;
    event.id = getGlobaleventInd();
    % disp(event.id);
    setGlobaleventInd(event.id + 1); % increase the eventInd, for the next event creation
    
    if exist('opts','var')
      event.pkt = opts.pkt;
      event.timerType = opts.timerType;      
    end
end
