function [output] = simulateNet(slotTime, simTime, numDevs, debMode, wantPlot, distFactor, dataRate, pktPolicy, resultsPath)
    %testing function, simulates a network with the given paraeters
    %   for now, numDevs can be 2 or 4 
    
    switch numDevs
        
        case 2
            %  for 2 devices, 1 pTp link:
            dev1P = createDevParams(1, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); % SIFS and SlotTime are in microseconds
            dev2P = createDevParams(2, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);

            link1 = createlinkInfo(1, 2, 6, dataRate, 100, 2000, 0, pktPolicy); % rates - in Mbps!! PHY rate and then APP (DATA) rate
            link2 = createlinkInfo(2, 1, 6, dataRate,  100, 2000, 0, pktPolicy);

            devsParams = {dev1P, dev2P};
            phyNetParams.numDevs = numDevs;
            phyNetParams.linksLens = distFactor*[0, 10; 10, 0]; % in KMs
            logNetParams.linksInfo = {link1, link2};
            simulationParams.finishTime = simTime; % in seconds
            simulationParams.debugMode = debMode;

        case 4
            % for 4 devices:
            dev1P = createDevParams(1, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); % SIFS and SlotTime are in microseconds
            dev2P = createDevParams(2, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);
            dev3P = createDevParams(3, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); 
            dev4P = createDevParams(4, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);

            link1 = createlinkInfo(1, 2, 6, dataRate, 100, 2000, 0, pktPolicy); % rates - in Mbps!! PHY rate and then APP (DATA) rate
            link2 = createlinkInfo(2, 1, 6, dataRate, 100, 2000, 0, pktPolicy);
            link3 = createlinkInfo(3, 4, 6, dataRate,  100, 2000, 0, pktPolicy);
            link4 = createlinkInfo(4, 3, 6, dataRate,  100, 2000, 0, pktPolicy);

            devsParams = {dev1P, dev2P, dev3P, dev4P};
            phyNetParams.numDevs = numDevs;
            phyNetParams.linksLens = getLinksLenfor4Devs(distFactor); % in KMs
            logNetParams.linksInfo = {link1, link2, link3, link4};
            simulationParams.finishTime = simTime; % in seconds
            simulationParams.debugMode = debMode;
            
        case 6
            % for 6 devices:
            dev1P = createDevParams(1, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); % SIFS and SlotTime are in microseconds
            dev2P = createDevParams(2, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);
            dev3P = createDevParams(3, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); 
            dev4P = createDevParams(4, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);
            dev5P = createDevParams(5, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);
            dev6P = createDevParams(6, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);

            link1 = createlinkInfo(1, 2, 6, dataRate, 100, 2000, 0, pktPolicy); % rates - in Mbps!! PHY rate and then APP (DATA) rate
            link2 = createlinkInfo(2, 1, 6, dataRate, 100, 2000, 0, pktPolicy);
            link3 = createlinkInfo(3, 4, 6, dataRate,  100, 2000, 0, pktPolicy);
            link4 = createlinkInfo(4, 3, 6, dataRate,  100, 2000, 0, pktPolicy);
            link5 = createlinkInfo(5, 6, 6, dataRate,  100, 2000, 0, pktPolicy);
            link6 = createlinkInfo(6, 5, 6, dataRate,  100, 2000, 0, pktPolicy);

            devsParams = {dev1P, dev2P, dev3P, dev4P, dev5P, dev6P};
            phyNetParams.numDevs = numDevs;
            phyNetParams.linksLens = getLinksLenfor6Devs(distFactor); % in KMs
            logNetParams.linksInfo = {link1, link2, link3, link4, link5, link6};
            simulationParams.finishTime = simTime; % in seconds
            simulationParams.debugMode = debMode;
                        
        otherwise
            fprintf('nuDevs can be 2 or 4 or 6, sorry...');
    end
    
    % now, run the simulator and then print the results
    [output] = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);

    disp('sim ended!');
    
    %saveResults(output, numDevs, resultsPath);
           
    % for plotting timelines and saving them to files in the folder
    % 'ResultsGraphs'
    if(wantPlot == 1)
        for s=1:numDevs
            devResPath = [resultsPath, '\Device_', int2str(s)];
            mkdir(devResPath);
            plotAllTimelinesForDev(s, output.eventsDS, simulationParams.finishTime, phyNetParams.numDevs, devResPath);
        end
    end

end

