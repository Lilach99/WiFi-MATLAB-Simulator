function [opts] = createOpts(pkt, timerType)
    %creates a struct with the optional parameters for event
    %   gets packet and timer type
    opts.pkt = pkt; 
    opts.timerType = timerType;
end