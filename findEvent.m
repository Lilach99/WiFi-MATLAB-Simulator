function [wantedEventInd] = findEvent(e, eventsList)
    % finds an event from the specified type of the specified station
    %   returns the index of the wanted event if exists
    eventTypesEnums = cellfun(@(s)s.type, eventsList,'uni',0);
    eventTypeNums = cellfun(@(s)double(s), eventTypesEnums,'uni',0); 
    eventsTypes = cell2mat(eventTypeNums);
    curTypeEvents = (eventsTypes == e.type); % binary rep. for only this type of event (1 for this type, 0 otherwise)
    
    eventsStations = cell2mat(cellfun(@(s)s.station, eventsList,'uni',0));
    curStationEvents = (eventsStations == e.station); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
    
    
    eventsTimes = cell2mat(cellfun(@(s)s.time, eventsList,'uni',false));
    curTimeEvents = (eventsTimes == e.time); % binary rep. 
    
    wantedEventInd = find(curStationEvents & curTypeEvents & curTimeEvents); % events which satisfies both conditions (should be only one...) 
end