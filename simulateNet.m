function [output] = simulateNet(slotTime, simTime, numDevs, debMode, wantPlot, distFactor)
    %testing function, simulates a network with the given paraeters
    %   for now, numDevs can be 2 or 4 
    
    switch numDevs
        
        case 2
            %  for 2 devices, 1 pTp link:
            dev1P = createDevParams(1, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc); % SIFS and SlotTime are in microseconds
            dev2P = createDevParams(2, 16*10^-6, slotTime, 14, backoffTechnique.WIFI, @ackLengthFunc, @pktLengthFunc);

            link1 = createlinkInfo(1, 2, 6, 0.1, 100, 2000, 0); % rates - in Mbps!! PHY rate and then APP (DATA) rate
            link2 = createlinkInfo(2, 1, 6, 0.1,  100, 2000, 0);

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

            link1 = createlinkInfo(1, 2, 6, 1, 100, 2000, 0); % rates - in Mbps!! PHY rate and then APP (DATA) rate
            link2 = createlinkInfo(2, 1, 6, 1,  100, 2000, 0);
            link3 = createlinkInfo(3, 4, 6, 1,  100, 2000, 0);
            link4 = createlinkInfo(4, 3, 6, 1,  100, 2000, 0);

            devsParams = {dev1P, dev2P, dev3P, dev4P};
            phyNetParams.numDevs = numDevs;
            phyNetParams.linksLens = getLinksLenfor4Devs(distFactor); % in KMs
            logNetParams.linksInfo = {link1, link2, link3, link4};
            simulationParams.finishTime = simTime; % in seconds
            simulationParams.debugMode = debMode;
            
        otherwise
            fprintf('nuDevs can be 2 or 4, sorry...');
    end
    
    % now, run the simulator and then print the results
    [output] = WiFiSimulator(devsParams, phyNetParams, logNetParams, simulationParams);

    disp(output);
    collDataBytesCtr = 0;
    collCtrlBytesCtr = 0;
    for p=1:numDevs
        disp(['Link Number ', int2str(p)]);
        disp(output.linksRes{p});
        collDataBytesCtr = collDataBytesCtr + output.linksRes{p}.dataCollCtr;
        collCtrlBytesCtr = collCtrlBytesCtr + output.linksRes{p}.ctrlCollCtr;
    end
    disp(['Total Number of Collided Data KBytes: ', int2str(collDataBytesCtr/10^3)]);
    disp(['Total Number of Collided Control KBytes: ', int2str(collCtrlBytesCtr/10^3)]);
           
    % for plotting timelines and saving them to files in the folder
    % 'ResultsGraphs'
    if(wantPlot == 1)
        for s=1:4
            plotAllTimelinesForDev(s, output.eventsDS, simulationParams.finishTime, phyNetParams.numDevs);
        end
    end

end

