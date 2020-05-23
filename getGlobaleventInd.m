function r = getGlobaleventInd()

persistent eventInd
if isempty(eventInd)
    eventInd = 0;
end

r = eventInd;
eventInd = eventInd + 1;