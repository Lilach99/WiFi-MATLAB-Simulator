function [devState] = createDevInitState(devParams, ackTO)
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
    devState.isACKToExp = 0; % a control it which should be 1 if an ACK TO occurred during ACK reception
                        
    devState.queue = createQueue(100); % the packets queue of the device, 100 is the intial size, it may grow
    
    devState.CWmin = 15;
    devState.CWmax = 1023;
    devState.curCWND = devState.CWmin;
    devState.curRet = 0; % number of retreis on the current packet
    devState.SSRC = 0; % number of retries of the station (STA short retry count, bacause we are not using RTS/CST)
    % NOTE THAT:
    % curRet increases whenever an unsuccessful transmission attempt of the
    % current packet occures, and it is being reset with every new packet 
    % or valid ACK arrival;
    % SSRC increases whenever ANY curRet increases, and is being reset on
    % every valid ACK arrival (so if we have a sequence of packet
    % discardings - SSRC will continue increasing while curRet will be
    % reset with every new packet!)
    % curCWND is being doubled upon a collision; it is being reset on every 
    % ACK arrival (successful transmission) and whenever SSRC reaches numRet 
    % (so if we have a sequence of packet discardings - curCWND won't be
    % reset!)
    
    devState.curBackoff = -1; % -1 stands for no ongoing backoff, the number is the amount of time we have to wait from now
    devState.startBackoffTime = -1; % -1 stands for no ongoing backoff, the number is the time when we started to count the backoff
    devState.isColl = 0;
    
    % Standard parameters    
    devState.dev = devParams.dev;
    devState.SIFS = devParams.SIFS;
    devState.ST = devParams.ST;
    devState.DIFS = devParams.SIFS + 2*devParams.ST;
    devState.numRet = devParams.numRet;
    devState.aggFactor = devParams.aggFactor;
    devState.backoffTech = devParams.backoffTech;
    devState.ackLenFunc = devParams.ackLenFunc;
    devState.ackTO = ackTO;
    devState.pktLenFunc = devParams.pktLenFunc;    
    
end