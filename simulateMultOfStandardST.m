function [] = simulateMultOfStandardST(dataRate, packetsPolicy, linkLens, STFactor)
    %simulates a link which uses STFactor*StandardST SlotTime
    
    simTime = 5; % in seconds
    numSims = 1; % number of simulations we run and average
    numDevs = 2;
    numDists = size(linkLens, 2);
    numSTVals = 6;
    [totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer] = initCommulativeMetricsDSs(numDists, numSTVals, numSims);
    [totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer] = initCommulativeMetricsDSs(numDists, numSTVals, numSims);

    % make directories to save the results:
    t = datetime('now');
    t = datestr(t);
    t = strrep(t,':','-');
    switch packetsPolicy
        case pktPolicy.CBR
            pktPol = 'CBR_1460B_packets';
        case pktPolicy.RAND
            pktPol = 'RAND_100B-2000B_packets';
    end
    experimentResultsPath = ['Results\Experiment_Various_ST_Values_Bunch_', pktPol, '_', int2str(dataRate), '_Mbps_data_rate_', int2str(numSims), '_Simulations_', int2str(numDevs/2), '_pTp_Links_', int2str(simTime), '_secondes_simulation_', t];
    mkdir(experimentResultsPath); % for this experiment

    for k=1:numSims
        
        % DSs for future display of the metrics of the links:
        link1InfoStandardST = cell(numDists, 1);
        link2InfoStandardST = cell(numDists, 1);
        link1Info2APDST = cell(numDists, 1);
        link2Info2APDST = cell(numDists, 1);
        
        % output arrays
        outputStandard = cell(numDists, 1);
        output2APD = cell(numDists, 1);

        tic
        for h=1:numDists
        %parfor h=1:numDists
          %dists = getLinksLenfor4Devs(h); % in KMs
          dists = linkLens(h)*[0, 1; 1, 0]; 
          %dists = getLinksLenfor6Devs(h); % in KMs
          standardST = 9*10^-6; % standard
          APDST = 10^-5+calcSTfromNetAPD(dists, 1); % 1 APD !

          disp(['Length of tested link: ', int2str(linkLens(h))]);

          disp('Standard');
          % Standard ST experiment
          resPath = 'lala'; % not used, dummy!
          %mkdir(resPath);
          outputStandard{h} = simulateNet(standardST*STFactor, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath); % the last parameter is dataRate in Mbps!
          link1InfoStandardST{h} = outputStandard{h}.linksRes{1};
          link2InfoStandardST{h} = outputStandard{h}.linksRes{2};

          disp('2APD');
          output2APD{h} = simulateNet(2*APDST, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath);
          link1Info2APDST{h} = output2APD{h}.linksRes{1};
          link2Info2APDST{h} = output2APD{h}.linksRes{2};

        end

        linkInfoStandardST{1} = link1InfoStandardST;
        linkInfoStandardST{2} = link2InfoStandardST;

        linkInfo2APDST{1} = link1Info2APDST;
        linkInfo2APDST{2} = link2Info2APDST;

        % for link 1:
        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{1}, linkInfo3APDST{1}, linkInfo2APDST{1}, linkInfoAPDST{1}, linkInfoHalfAPDST{1}, linkInfoQrtAPDST{1}, simTime, numSTVals, numDists);
        [totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer] = addLinkInfoRes(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, linkThpts, linkGoodpts, linkCollPer, k, numSTVals); % add the results to the commulative results - for averaging later

        % for link 2:
        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{2}, linkInfo3APDST{2}, linkInfo2APDST{2}, linkInfoAPDST{2}, linkInfoHalfAPDST{2}, linkInfoQrtAPDST{2}, simTime, numSTVals, numDists);
        [totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer] = addLinkInfoRes(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, linkThpts, linkGoodpts, linkCollPer, k, numSTVals); % add the results to the commulative results - for averaging later

        save([experimentResultsPath, '\output_', int2str(k), '.mat']);

    end
    toc

    setUpTitle = [int2str(numDevs), ' point to point link, 1460B packets, ', int2str(simTime), ' seconds simulation'];

    %tic
    % for link 1:
    resultsPath = [experimentResultsPath, '\Link_', int2str(1)];
    mkdir(resultsPath);
    [totalLink1ThptsAVG, totalLink1GoodptsAVG, totalLink1CollPerAVG] = calcAvg(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsAvg(totalLink1ThptsAVG, totalLink1GoodptsAVG, totalLink1CollPerAVG, linkLens, resultsPath, [setUpTitle, ' - Mean of ', int2str(numSims), ' simulations'], dataRate);
    [totalLink1ThptsSTDEV, totalLink1GoodptsSTDEV, totalLink1CollPerSTDEV] = calcStandardDev(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsStdDev(totalLink1ThptsSTDEV, totalLink1GoodptsSTDEV, totalLink1CollPerSTDEV, linkLens, resultsPath, [setUpTitle, ' - Standard deviation of ', int2str(numSims), ' simulations']);

    % for link 2:
    resultsPath = [experimentResultsPath, '\Link_', int2str(2)];
    mkdir(resultsPath);
    [totalLink2ThptsAVG, totalLink2GoodptsAVG, totalLink2CollPerAVG] = calcAvg(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsAvg(totalLink2ThptsAVG, totalLink2GoodptsAVG, totalLink2CollPerAVG, linkLens, resultsPath, [setUpTitle, ' - Mean of ', int2str(numSims), ' simulations'], dataRate);
    [totalLink2ThptsSTDEV, totalLink2GoodptsSTDEV, totalLink2CollPerSTDEV] = calcStandardDev(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsStdDev(totalLink2ThptsSTDEV, totalLink2GoodptsSTDEV, totalLink2CollPerSTDEV, linkLens, resultsPath, [setUpTitle, ' - Standard deviation of ', int2str(numSims), ' simulations']);


    %toc

    save([experimentResultsPath, '\output.mat']);
    

end

