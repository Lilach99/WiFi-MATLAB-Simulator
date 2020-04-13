function [lastEventInd] = findLastCurEvent(simEventsList, curTime)
    %finds the index of the last event which happens at this point in time
    
    lastEventInd = 1;
    time = curTime;
    while((time == curTime) && (lastEventInd <= size(simEventsList, 2)))
        time = simEventsList{lastEventInd}.time; % assume there are at least 2 simEvents int the array
        lastEventInd = lastEventInd + 1;
    end 
    lastEventInd = lastEventInd - 1; % we increased i one time extra
end