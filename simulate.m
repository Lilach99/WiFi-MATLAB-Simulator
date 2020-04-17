import mlreportgen.dom.*;

% "defines":
numPackets = 10;
packetSize = 1460; % In bytes

ST=9; % In microseconds
SIFS=16; % In microseconds
ackSize=14; % In bytes, according to page 405 in the standard
ackTO=1; % In miliseconds, the formula is: ACK Timeout = Air Propagation Time (max) + SIFS + Time to transmit 14 byte ACK frame [14 * 8 / bitrate in Mbps] + Air Propagation Time (max)
numRet=4;
linkRate=1; % In Mbps
tranRateA=1; % In Mbps
tranRateB=1; % In Mbps
TranRates = [tranRateA, tranRateB];
% Constant initiation of the packets array:
packetsA = ones(1, numPackets)*packetSize;
packetsB = ones(1, numPackets)*packetSize;
packetsToSend = [packetsA, packetsB];
packetLossPer = 0;
ackDur = ackSize/tranRateA; % In microseconds - TODO: check if there is a special rate for control frames
FinishTime = 1000000000;
interArr = 2; % IAT in seconds
NumOfDevs = 2;

% tests: 

dev1P = createDevParams(1, 16, 9, 14, 14, 50, @pktLengthFunc); % abs is just some unary function, for testing
dev2P = createDevParams(2, 16, 9, 14, 14, 50, @pktLengthFunc);

link1 = createlinkInfo(1, 2, 5, 10, 200, 2000, 0);
link2 = createlinkInfo(2, 1, 5, 10, 100, 900, 0);

devsParams = {dev1P, dev2P};
phyNetParams.numDevs = 2;
phyNetParams.linksLens = [0, 10000; 10000, 0]; % in meters
logNetParams.linksInfo = {link1, link2};
simulationParams.finishTime = 200;
simulationParams.debugMode = 1;

[output] = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);




