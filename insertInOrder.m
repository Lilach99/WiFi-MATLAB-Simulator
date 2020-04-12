function [eventsList] = insertInOrder(eventsList, newEvent)
    % inserts the newEvent to the lists, according to the sort
    % order of times
    %   gets the new event and the array, and returns the
    %   updated array with the new value in the right places
    eventsList{size(eventsList, 2) + 1} = newEvent;
    [~,TimeSort]=sort(cell2mat((cellfun(@(s)s.time, eventsList,'uni',0)))); %Get the sorted order of times
    eventsList = eventsList(TimeSort);
end