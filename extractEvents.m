function [desEvents] = extractEvents(station, type, events)
%retrieves only the events from the given type which relate to the given
%station, from the given events list

% we have to find the station-related events and the relevant-type-events,
% so extract the stations and types to different vectors for later comparison
eventsStations = cell2mat(cellfun(@(s)s.station, events,'uni',0)); 
eventTypesEnums = cellfun(@(s)s.type, events,'uni',0);
eventTypeNums = cellfun(@(s)double(s), eventTypesEnums,'uni',0); 
eventsTypes = cell2mat(eventTypeNums);
        
% eventsStations = [events.station];
% eventTypeEnums = [events.type];
% eventsTypes = double(eventTypeEnums);

switch type
     
     case eventType.TRAN
        % find only the events which relate to 'station' and are
        % transmitting events (START or RECEIVE)
        desEventsInds = (eventsStations == station)&(eventsTypes == simEventType.TRAN_START | eventsTypes == simEventType.TRAN_END);
        desEvents = events(desEventsInds);
       
     case eventType.REC
        % find only the events which relate to 'station' and are
        % receiving events (START or RECEIVE)
        desEventsInds = (eventsStations == station)&(eventsTypes == simEventType.REC_START | eventsTypes == simEventType.REC_END);
        desEvents = events(desEventsInds);

     otherwise
         fprinf('illegal event type to extract!');
 end
 
end

