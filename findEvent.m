function [wantedEventInd] = findEvent(station, eventType, eventsList)
    % finds an event from the specified type of the specified station
    %   returns the index of the wanted event if exists
    eventsStations = cell2mat(cellfun(@(s)s.station,eventsList,'uni',0));
    curStationEvents = (eventsStations == station); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
    eventsTypes = cell2mat(cellfun(@(s)s.type,eventsList,'uni',false));
    curTypeEvents = (eventsTypes == eventType); % binary rep. for only this type of event (1 for this type, 0 otherwise)
    wantedEventInd = find(curStationEvents & curTypeEvents); % events which satisfies both conditions (should be only one...) 
end