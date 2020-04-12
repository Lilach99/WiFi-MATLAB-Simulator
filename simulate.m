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

dev1P.SIFS = 16;
dev1P.ST = 9;
dev1P.numRet = 14;
dev1P.ackDur = 14;
dev1P.ackTO = 500;
dev1P.pktLenFunc = @max;

dev2P.SIFS = 16;
dev2P.ST = 9;
dev2P.numRet = 14;
dev2P.ackDur = 14;
dev2P.ackTO = 2000;
dev2P.pktLenFunc = @max;



devsParams = {dev1P, dev2P};
phyNetParams.numDevs = 2;
phyNetParams.linksLens = [0, 10; 10, 0]; % in KMs
logNetParams = sysConst.NONE;
simulationParams.finishTime = 25;
simulationParams.debugMode = 0;



