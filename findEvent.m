function [wantedEventArrInd] = findEvent(eventID, eventStation, eventsList)
    % finds an event from the specified type of the specified station
    %   returns the index of the wanted event if exists
    
%     eventTypesEnums = cellfun(@(s)s.type, eventsList,'uni',0);
%     eventTypeNums = cellfun(@(s)double(s), eventTypesEnums,'uni',0); 
%     eventsTypes = cell2mat(eventTypeNums);
%     curTypeEvents = (eventsTypes == e.type); % binary rep. for only this type of event (1 for this type, 0 otherwise)
%     
%     eventsStations = cell2mat(cellfun(@(s)s.station, eventsList,'uni',0));
%     curStationEvents = (eventsStations == e.station); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
%     
%     eventsTimes = cell2mat(cellfun(@(s)s.time, eventsList,'uni',false));
%     curTimeEvents = (eventsTimes == e.time); % binary rep. 
%     
%     timerTypesEnums = cellfun(@(s)s.timerType, eventsList,'uni',false);
%     timerTypeNums = cellfun(@(s)double(s), timerTypesEnums,'uni',0); 
%     eventsTimerTypes = cell2mat(timerTypeNums);
    
%     allCN = [eventsList.id]; % comma separated list expansion 
    id_ind = [eventsList.id] == eventID;
    station_ind = [eventsList.station] == eventStation;
    wantedEventArrInd = find(id_ind & station_ind); % events which satisfies both conditions - just in case  

    
%     eventsIDs = cell2mat(cellfun(@(s)s.id, eventsList,'uni',0));
%     curIDEvent = (eventsIDs == eventID); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
%     
%     eventsStations = cell2mat(cellfun(@(s)s.station, eventsList,'uni',0));
%     curStationEvents = (eventsStations == eventStation); % binary rep. for only this station's events (1 for this station's events, 0 otherwise)
% 
%     wantedEventArrInd = find(curIDEvent & curStationEvents); % events which satisfies both conditions - just in case 
    
    % disp(wantedEventArrInd);
    
end