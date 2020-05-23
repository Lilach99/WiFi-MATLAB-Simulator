function [orderedEvents, handlingOrder] = sortByHandlingOrder(events)
    %sorts a list of events according to their desired order of handling
    %   this is done according to the simEventType enum field, the time of
    %   all of the evnets should be the same time (otherwise we do not need
    %   this sorting)
    orderedEvents = events;
    handlingOrder = [1];
    if (length(events) > 1)
        [~,handlingOrder]=sort([events.type]);
        orderedEvents = events(handlingOrder);
    end
    
%     eventTypesEnums = cellfun(@(s)s.type, events,'uni',0);
%     eventTypeNums = cellfun(@(s)double(s), eventTypesEnums,'uni',0); 
%     [~,handlingOrder]=sort(cell2mat(eventTypeNums)); % get the sorted order of handling
%     orderedEvents = events(handlingOrder);
    
end