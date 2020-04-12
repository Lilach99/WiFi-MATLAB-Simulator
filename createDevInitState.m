function [devState] = createDevInitState(devParams, dev)
    %creates an initialized struct for the input station's state
    %   gets the station and returns its state struct
    
    devState.dev = dev;
    devState.medCtr = 0; % will be 0 if no ones uses the medium right now
    devState.wasBusy=0; % will be 1 if the medium was busy sometime  since the previous event
    devState.curState = devStateType.IDLE; % state from the state machine
    devState.sucSentBytes = 0; % Number of packets/bytes it successfully sent until now
    devState.recBytes = 0; % number of packets/bytes it received since simulation started
    devState.curPkt = sysConst.NONE; % the packet that the station is trying to transmit using CSMA/CA or the packet that the station is transmitting now
    devState.queue = {}; % number of packets in the station s queue/maybe the whole packets queue of the device
    devState.curRet = 0; % number of retreis on the current packet
    devState.curBackoff = -1; % -1 stands for no ongoing backoff, the number is the amount of time we have to wait from now
    devState.startBackoffTime = -1; % -1 stands for no ongoing backoff, the number is the time when we started to count the backoff
    
    devState.curCWND = 1;
    devState.CWmax = 1023;
    
    % Standard parameters
    devState.SIFS = devParams.SIFS;
    devState.ST = devParams.ST;
    devState.DIFS = devParams.SIFS + 2*devParams.ST;
    devState.numRet = devParams.numRet;
    devState.ackDur = devParams.ackDur;
    devState.ackTO = devParams.ackTO;
    devState.pktLenFunc = devParams.pktLenFunc;
    
    
end