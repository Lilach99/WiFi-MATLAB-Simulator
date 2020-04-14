function [updatedList] = updateEventsList(newEvents, curTime, curTimeEvents)
    %add new events to the list if they happen at time 'curTime'
    %   useful for adding new events to the simulation events list, so we
    %   can handle them before increasing 'curTime'
    eventsTimes = cell2mat(cellfun(@(s)s.time,newEvents,'uni',0));
    curTimeEvents = newEvents(eventsTimes == curTime); % binary rep. for the events happens at'curTime' (1 for 'curTime' events, 0 otherwise)
    updatedList = sortByHandlingOrder([newEvents, curTimeEvents]); % add new 'curTime' events to the list, and sort according to the handling order
    
end

