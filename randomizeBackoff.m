function [backoff] = randomizeBackoff(devState)
    %returns the backoff for the device - a new randomized one or an
    %existing one, according to the device's state

    if(devState.curBackoff == -1)
        % we have to randomize the backoff
        backoff = devState.ST*rand(1, devState.curCWND);
    else
        % there is an active backoff already
        backoff = devState.curBackoff;
    end
end