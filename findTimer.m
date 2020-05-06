function [wantedTimerInd] = findTimer(station, timerType, eventsList)
    % finds an timer event from the specified type of the specified station
    %   returns the index of the wanted timer event if exists
    
%     eventsStations = cell2mat(cellfun(@(s)s.station,eventsList,'uni',0));
%     curStationEvents = (eventsStations == station); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
    curStationEvents = [eventsList.station] == station;
    
%     eventTypesEnums = cellfun(@(s)s.type, eventsList,'uni',0);
%     eventTypesEnums = [eventsList.type];
%     eventTypeNums = cellfun(@(s)double(s), eventTypesEnums,'uni',0); 
%     eventsTypes = cell2mat(eventTypeNums);
    timerEvents = ([eventsList.type] == simEventType.SET_TIMER);
    
%     timerTypesEnums = cellfun(@(s)s.timerType, eventsList,'uni',false);
%     timerTypeNums = cellfun(@(s)double(s), timerTypesEnums,'uni',0); 
%     eventsTimerTypes = cell2mat(timerTypeNums);
%     curTimerTypeEvents = (eventsTimerTypes == timerType); % binary rep. for only this type of event (1 for this type, 0 otherwise)
    curTimerTypeEvents = ([eventsList.timerType] == timerType);
    
    
    wantedTimerInd = find(curStationEvents & curTimerTypeEvents & timerEvents); % events which satisfies both conditions (should be only one...) 
end