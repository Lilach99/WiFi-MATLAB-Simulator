function [] = analayzeResults(outputsPath, toWritePath, numDists, numSTVals, numSims)
    %gets a path were all of the .mat output files are saved, analayzes
    %these results and plots the corresponding graphs - it's for 1 rate!
    
    [totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer] = initCommulativeMetricsDSs(numDists, numSTVals, numSims);
    [totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer] = initCommulativeMetricsDSs(numDists, numSTVals, numSims);
    mkdir(toWritePath);

    % LOAD .mat file from the given outputPathes directory
    % work on it - those variables appear in the workspace:
    outputsList = dir(fullfile(outputsPath, '*.mat'));
    for simInd=1:length(outputsList)
        load(fullfile(outputsPath, outputsList(simInd).name));
        setUpTitle = [int2str(numDevs/2), ' point to point link, ', num2str(dataRate), ' Mbps, ', pktPol, ' ', int2str(simTime), ' seconds simulation'];
        % assume 2 devices for now
        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{1}, linkInfo3APDST{1}, linkInfo2APDST{1}, linkInfoAPDST{1}, linkInfoHalfAPDST{1}, linkInfoQrtAPDST{1}, simTime, numSTVals, numDists);
        [totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer] = addLinkInfoRes(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, linkThpts, linkGoodpts, linkCollPer, simInd, numSTVals);

        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{2}, linkInfo3APDST{2}, linkInfo2APDST{2}, linkInfoAPDST{2}, linkInfoHalfAPDST{2}, linkInfoQrtAPDST{2}, simTime, numSTVals, numDists);
        [totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer] = addLinkInfoRes(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, linkThpts, linkGoodpts, linkCollPer, simInd, numSTVals);
    end
    
    % now, calculate mean and std and plot results graphs
    % for link 1:
    [totalLink1ThptsAVG, totalLink1GoodptsAVG, totalLink1CollPerAVG] = calcAvg(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsAvg(totalLink1ThptsAVG, totalLink1GoodptsAVG, totalLink1CollPerAVG, linkLens, toWritePath, [setUpTitle, ' link 1 - Mean of ', int2str(numSims), ' simulations'], dataRate);
    [totalLink1ThptsSTDEV, totalLink1GoodptsSTDEV, totalLink1CollPerSTDEV] = calcStandardDev(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsStdDev(totalLink1ThptsSTDEV, totalLink1GoodptsSTDEV, totalLink1CollPerSTDEV, linkLens, toWritePath, [setUpTitle, ' link 1 - Standard deviation of ', int2str(numSims), ' simulations']);

    % for link 2:
    [totalLink2ThptsAVG, totalLink2GoodptsAVG, totalLink2CollPerAVG] = calcAvg(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsAvg(totalLink2ThptsAVG, totalLink2GoodptsAVG, totalLink2CollPerAVG, linkLens, toWritePath, [setUpTitle, ' link 2 - Mean of ', int2str(numSims), ' simulations'], dataRate);
    [totalLink2ThptsSTDEV, totalLink2GoodptsSTDEV, totalLink2CollPerSTDEV] = calcStandardDev(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, numSTVals, numDists);
    plotLinkMetricsForDifferentSTsStdDev(totalLink2ThptsSTDEV, totalLink2GoodptsSTDEV, totalLink2CollPerSTDEV, linkLens, toWritePath, [setUpTitle, ' link 2 - Standard deviation of ', int2str(numSims), ' simulations']);


end
