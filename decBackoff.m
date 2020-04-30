function [newBackoff] = decBackoff(devState, curTime)
    %devrease the backoff counter of the device, to a whole number of ST's,
    %using rounding to the next bigger integer
    
    backoffInSlots = devState.curBackoff/devState.ST;
    timePassedInSlots =  floor((curTime - devState.startBackoffTime)/devState.ST); % floor because we do not want to count the last Slot - it's the slot when the medium became busy
    newBackoff = (backoffInSlots - timePassedInSlots)*devState.ST; % the remaining time to count, a whole number of STs

end

