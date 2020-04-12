function [eventsList] = saveNewEvents(newEvents, eventsList)
    %inserts the new events it gets (if exist) to the events queue of the
    %simuation
    %   the insertion is done in a chronological order, the variable
    %   'newEvents' is a small cell array of 'event' structs
    %  (usually 0, 1 or 2 cells)
    
    for i=1:size(newEvents, 2)
        eventsList{size(eventsList, 2) + 1} = newEvents(i);
    end
    [~,TimeSort]=sort(cell2mat((cellfun(@(s)s.time, eventsList,'uni',0)))); %Get the sorted order of times
    eventsList = eventsList(TimeSort);
    
end