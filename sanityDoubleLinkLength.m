import mlreportgen.dom.*;

% this script runs 2 siulations:
% 1. standard ST, SIFS, 1Mbps, 1460B packets, 1 pTp 10kms link
% 2. 2*(standard ST), 2*SIFS, 0.5Mbps, 1460B packets with Dup length, 1 pTp 20kms link
% the results should be the same - it's just a scaling...

SIFS = 16*10^-6;
slotTime = 9*10^-6;
dataRate = 1;
simTime = 15;
numDevs = 2;
numDists = 2;
linkLens = [10, 20];

% DSs for future display of the metrics of the links:
link1InfoStandardST = cell(numDists, 1);
link1InfoAPDST = cell(numDists, 1);
link2InfoStandardST = cell(numDists, 1);
link2InfoAPDST = cell(numDists, 1);

% make directories to save the results:
t = datetime('now');
t = datestr(t);
t = strrep(t,':','-');
experimentResultsPath = ['Results\Experiment_SANITY_DOUBLE_LENGTH_', int2str(numDevs/2), '_pTp_Links_', int2str(simTime), '_secondes_simulation_', t];
mkdir(experimentResultsPath); % for this experiment
standardSTPath = [experimentResultsPath, '\Standard_ST'];
mkdir(standardSTPath); % standard ST

% output arrays
outputStandard = cell(numDists, 1);

% experiment 1:
resPath = [standardSTPath, '\Length_', int2str(10)];
mkdir(resPath);
dev1P = createDevParams(1, SIFS, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); % SIFS and SlotTime are in microseconds
dev2P = createDevParams(2, SIFS, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);
link1 = createlinkInfo(1, 2, 6, dataRate, 100, 2000, 0, pktPolicy.RAND); % rates - in Mbps!! PHY rate and then APP (DATA) rate
link2 = createlinkInfo(2, 1, 6, dataRate,  100, 2000, 0, pktPolicy.RAND);
devsParams = {dev1P, dev2P};
phyNetParams.numDevs = numDevs;
phyNetParams.linksLens = [0, 10; 10, 0]; % in KMs
logNetParams.linksInfo = {link1, link2};
simulationParams.finishTime = simTime; % in seconds
simulationParams.debugMode = 0;
% now, run the simulator and then print the results
outputStandard{1} = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);
disp('sim ended!');
saveResults(outputStandard{1}, numDevs, resPath);
link1InfoStandardST{1} = outputStandard{1}.linksRes{1};
link2InfoStandardST{1} = outputStandard{1}.linksRes{2};

% experiment 2:
resPath = [standardSTPath, '\Length_', int2str(20)];
mkdir(resPath);
dev1P = createDevParams(1, 2*SIFS, 2*slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFuncDup); % SIFS and SlotTime are in microseconds
dev2P = createDevParams(2, 2*SIFS, 2*slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFuncDup);
link1 = createlinkInfo(1, 2, 6, 0.5*dataRate, 100, 2000, 0, pktPolicy.RAND); % rates - in Mbps!! PHY rate and then APP (DATA) rate
link2 = createlinkInfo(2, 1, 6, 0.5*dataRate,  100, 2000, 0, pktPolicy.RAND);
devsParams = {dev1P, dev2P};
phyNetParams.numDevs = numDevs;
phyNetParams.linksLens = 2*[0, 10; 10, 0]; % in KMs
logNetParams.linksInfo = {link1, link2};
simulationParams.finishTime = simTime; % in seconds
simulationParams.debugMode = 0;
% now, run the simulator and then print the results
outputStandard{2} = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);
disp('sim ended!');
saveResults(outputStandard{2}, numDevs, resPath);
link1InfoStandardST{2} = outputStandard{2}.linksRes{1};
link2InfoStandardST{2} = outputStandard{2}.linksRes{2};

% plot all of the results - comperative graphs:
linkInfoStandardST{1} = link1InfoStandardST;
linkInfoStandardST{2} = link2InfoStandardST;

% for h=1:numDevs
%     resultsPath = [experimentResultsPath, '\Link_', int2str(h)];
%     mkdir(resultsPath);
%     plotLinkMetrics(linkInfoStandardST{h}, linkInfoAPDST{h}, linkLens, simTime, resultsPath);
% end

save([experimentResultsPath, '\output.mat']);

