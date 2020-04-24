import mlreportgen.dom.*;

% tests: 

dev1P = createDevParams(1, 16, 9, 14, @ackLengthFunc, 7000000, @pktLengthFunc); % SIFS and SlotTime and ackTO are in microseconds
dev2P = createDevParams(2, 16, 9, 14, @ackLengthFunc, 7000000, @pktLengthFunc);
dev3P = createDevParams(3, 16, 9, 14, @ackLengthFunc, 7000000, @pktLengthFunc); 
dev4P = createDevParams(4, 16, 9, 14, @ackLengthFunc, 7000000, @pktLengthFunc);

link1 = createlinkInfo(1, 2, 6, 0.1, 200, 2000, 0); % rates - in Mbps!! PHY rate and then APP (DATA) rate
link2 = createlinkInfo(2, 1, 6, 0.1, 100, 900, 0);
link3 = createlinkInfo(3, 4, 6, 0.1, 200, 2000, 0);
link4 = createlinkInfo(4, 3, 6, 0.1, 100, 900, 0);

devsParams = {dev1P, dev2P, dev3P, dev4P};
phyNetParams.numDevs = 4;
phyNetParams.linksLens = [0, 1, 2, 2.236; 1, 0, 2.236, 2; 2, 2.236, 0, 1; 2.236, 2, 1, 0]; % in KMs
logNetParams.linksInfo = {link1, link2, link3, link4};
simulationParams.finishTime = 1; % in seconds
simulationParams.debugMode = 1;

[output] = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);

disp(output);

for p=1:4
    disp(p);
    disp(output.linksRes{p});
end
  



