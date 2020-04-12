function [event] = createEvent(type, time, station, opts)
    % creates an event as specifed and returns it
    %  the 'packet' parameter is optional, there are events which does not
    %  relates to a specific packet...
    event.type = type;
    event.time = time;
    event.station = station;
    event.pkt = packetType.NONE;
    event.timerType = timerType.NONE;
    if exist('opts','var')
      event.pkt = opts.pkt;
      event.timerType = opts.timerType;      
    end
end
