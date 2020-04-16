function [devState] = createDevInitState(devParams)
    %creates an initialized struct for the input station's state
    %   gets the station and returns its state struct
    

    devState.medCtr = 0; % will be 0 if no ones uses the medium right now
    devState.curState = devStateType.IDLE; % state from the state machine
    devState.sucSentBytes = 0; % Number of packets/bytes it successfully sent until now
    devState.recBytes = 0; % number of packets/bytes it received since simulation started
    devState.lostBytes = 0; % number of lost bytes (which the device failed to send)
    devState.curPkt = emptyPacket(); % the packet that the station is trying to transmit using CSMA/CA or the packet that the station is transmitting now
    devState.curRecPkt = emptyPacket(); 
    devState.isWaitingForACK = 0; % a control bit which should be 1 iff the device is waiting for ACK (otherwise it's 0)
    
    devState.queue = createQueue(100); % the packets queue of the device, 100 is the intial size, it may grow
    devState.curRet = 0; % number of retreis on the current packet
    devState.curBackoff = -1; % -1 stands for no ongoing backoff, the number is the amount of time we have to wait from now
    devState.startBackoffTime = -1; % -1 stands for no ongoing backoff, the number is the time when we started to count the backoff
    devState.isColl = 0;
    
    devState.curCWND = 1;
    devState.CWmax = 1023;
    
    % Standard parameters    
    devState.dev = devParams.dev;
    devState.SIFS = devParams.SIFS;
    devState.ST = devParams.ST;
    devState.DIFS = devParams.SIFS + 2*devParams.ST;
    devState.numRet = devParams.numRet;
    devState.ackDur = devParams.ackDur;
    devState.ackTO = devParams.ackTO;
    devState.pktLenFunc = devParams.pktLenFunc;
    
    
end