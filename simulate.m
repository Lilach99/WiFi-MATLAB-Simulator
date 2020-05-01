import mlreportgen.dom.*;

% tests: 
% for 4 devices:
dev1P = createDevParams(1, 16, 9, 14, @ackLengthFunc, @pktLengthFunc); % SIFS and SlotTime and ackTO are in microseconds
dev2P = createDevParams(2, 16, 9, 14, @ackLengthFunc, @pktLengthFunc);
dev3P = createDevParams(3, 16, 9, 14, @ackLengthFunc, @pktLengthFunc); 
dev4P = createDevParams(4, 16, 9, 14, @ackLengthFunc, @pktLengthFunc);

link1 = createlinkInfo(1, 2, 6, 0.1, 100, 2000, 0); % rates - in Mbps!! PHY rate and then APP (DATA) rate
link2 = createlinkInfo(2, 1, 6, 0.1,  100, 2000, 0);
link3 = createlinkInfo(3, 4, 6, 0.1,  100, 2000, 0);
link4 = createlinkInfo(4, 3, 6, 0.1,  100, 2000, 0);

devsParams = {dev1P, dev2P, dev3P, dev4P};
phyNetParams.numDevs = 4;
phyNetParams.linksLens = 0.01*[0, 10, 20, 22.36; 10, 0, 22.36, 20; 20, 22.36, 0, 10; 22.36, 20, 10, 0]; % in KMs
logNetParams.linksInfo = {link1, link2, link3, link4};
simulationParams.finishTime = 10; % in seconds
simulationParams.debugMode = 1;

% %  for 2 devices, 1 pTp link:
% 
% dev1P = createDevParams(1, 16, 9, 14, @ackLengthFunc, 7000000, @pktLengthFunc); % SIFS and SlotTime and ackTO are in microseconds
% dev2P = createDevParams(2, 16, 9, 14, @ackLengthFunc, 7000000, @pktLengthFunc);
% 
% 
% link1 = createlinkInfo(1, 2, 6, 0.1, 100, 2000, 0); % rates - in Mbps!! PHY rate and then APP (DATA) rate
% link2 = createlinkInfo(2, 1, 6, 0.1,  100, 2000, 0);
% 
% 
% devsParams = {dev1P, dev2P};
% phyNetParams.numDevs = 2;
% phyNetParams.linksLens = [0, 10; 10, 0]; % in KMs
% logNetParams.linksInfo = {link1, link2};
% simulationParams.finishTime = 10; % in seconds
% simulationParams.debugMode = 1;

[output] = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);

disp(output);

for p=1:4
    disp(p);
    disp(output.linksRes{p});
end
  
% for plotting timelines and saving them to files in the folder
% 'ResultsGraphs'
if(simulationParams.debugMode)
    for s=1:4
        plotAllTimelinesForDev(s, output.eventsDS, simulationParams.finishTime, phyNetParams.numDevs);
    end
end


