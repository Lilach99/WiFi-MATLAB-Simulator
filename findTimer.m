function [wantedTimerInd] = findTimer(station, timerType, eventsList)
    % finds an timer event from the specified type of the specified station
    %   returns the index of the wanted timer event if exists
    eventsStations = cell2mat(cellfun(@(s)s.station,eventsList,'uni',0));
    curStationEvents = (eventsStations == station); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
    
     eventTypesEnums = cellfun(@(s)s.type, eventsList,'uni',0);
    eventTypeNums = cellfun(@(s)double(s), eventTypesEnums,'uni',0); 
    eventsTypes = cell2mat(eventTypeNums);
    timerEvents = eventsList(eventsTypes == simEventType.SET_TIMER);
    
    eventsTimerTypes = cell2mat(cellfun(@(s)s.timerType, eventsList,'uni',false));
    curTimerTypeEvents = (eventsTimerTypes == timerType); % binary rep. for only this type of event (1 for this type, 0 otherwise)
    
    wantedTimerInd = find(curStationEvents & curTimerTypeEvents); % events which satisfies both conditions (should be only one...) 
end