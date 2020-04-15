function [lastEventInd] = findLastCurEvent(simEventsList, curTime)
    %finds the index of the last event which happens at this point in time
    
    lastEventInd = 1;
    time = simEventsList{lastEventInd}.time;
    
    while((time == curTime) && (lastEventInd + 1 <= size(simEventsList, 2)))
        lastEventInd = lastEventInd + 1;
        time = simEventsList{lastEventInd}.time; % assume there are at least 2 simEvents int the array
    end 
    
    if(time~=curTime)
        lastEventInd = lastEventInd - 1; % we might have increased the index one time extra
    end
end