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
        setUpTitle = [int2str(numDevs/2), ' point to point bidirectional link, ', num2str(dataRate), ' Mbps each side, ', pktPol, ' ', int2str(simTime), ' seconds simulation'];
        % assume 2 devices for now
        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{1}, linkInfo3APDST{1}, linkInfo2APDST{1}, linkInfoAPDST{1}, linkInfoHalfAPDST{1}, linkInfoQrtAPDST{1}, simTime, numSTVals, numDists);
        [totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer] = addLinkInfoRes(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, linkThpts, linkGoodpts, linkCollPer, simInd, numSTVals);

        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{2}, linkInfo3APDST{2}, linkInfo2APDST{2}, linkInfoAPDST{2}, linkInfoHalfAPDST{2}, linkInfoQrtAPDST{2}, simTime, numSTVals, numDists);
        [totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer] = addLinkInfoRes(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, linkThpts, linkGoodpts, linkCollPer, simInd, numSTVals);
    end
    
    % now, calculate mean and std and plot results graphs
%     % for link 1:
%     [totalSide1ThptsAVG, totalSide1GoodptsAVG, totalSide1CollPerAVG] = calcAvg(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, numSTVals, numDists);
%     [totalLink1ThptsSTDEV, totalLink1GoodptsSTDEV, totalLink1CollPerSTDEV] = calcStandardDev(totalLink1Thpts, totalLink1Goodpts, totalLink1CollPer, numSTVals, numDists);
% 
%     % for link 2:
%     [totalSide2ThptsAVG, totalSide2GoodptsAVG, totalSide2CollPerAVG] = calcAvg(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, numSTVals, numDists);
%    % plotLinkMetricsForDifferentSTsAvg(totalLink2ThptsAVG, totalLink2GoodptsAVG, totalLink2CollPerAVG, linkLens, toWritePath, [setUpTitle, ' link 2 - Mean of ', int2str(numSims), ' simulations'], dataRate);
%     [totalSide2ThptsSTDEV, totalSide2GoodptsSTDEV, totalSide2CollPerSTDEV] = calcStandardDev(totalLink2Thpts, totalLink2Goodpts, totalLink2CollPer, numSTVals, numDists);
%    % plotLinkMetricsForDifferentSTsStdDev(totalLink2ThptsSTDEV, totalLink2GoodptsSTDEV, totalLink2CollPerSTDEV, linkLens, toWritePath, [setUpTitle, ' link 2 - Standard deviation of ', int2str(numSims), ' simulations']);

    % plots - for both of them, for the link:
    totalThpts = totalLink1Thpts + totalLink2Thpts;
    totalGoodputs = totalLink1Goodpts + totalLink2Goodpts;
    totalCollPer = (totalLink1CollPer + totalLink2CollPer)/2;
    [totalLinkThptsAVG, totalLinkGoodptsAVG, totalLinkCollPerAVG] = calcAvg(totalThpts, totalGoodputs, totalCollPer, numSTVals, numDists);
    [totalLinkThptsSTDEV, totalLinkGoodptsSTDEV, totalLinkCollPerSTDEV] = calcStandardDev(totalThpts, totalGoodputs, totalCollPer, numSTVals, numDists);
    [totalLinkThptsNeg, totalLinkGoodptsNeg, totalLinkCollPerNeg] = calcNeg(totalThpts, totalGoodputs, totalCollPer, numSTVals, numDists);
    [totalLinkThptsPos, totalLinkGoodptsPos, totalLinkCollPerPos] = calcPos(totalThpts, totalGoodputs, totalCollPer, numSTVals, numDists);
    %plotLinkMetricsForDifferentSTsAvg(totalLinkThptsAVG, totalLinkGoodptsAVG, totalLinkCollPerAVG, linkLens, toWritePath, [setUpTitle, ' link 1 - Mean of ', int2str(numSims), ' simulations'], dataRate);
    plotLinkMetricsForDifferentSTsStdDev(totalLinkThptsSTDEV, totalLinkGoodptsSTDEV, totalLinkCollPerSTDEV, linkLens, toWritePath, [setUpTitle, ' link 1 - Standard deviation of ', int2str(numSims), ' simulations']);
    plotLinkMetricsForDifferentSTsAvgWithErrorbar(totalLinkThptsAVG, totalLinkGoodptsAVG, totalLinkCollPerAVG, totalLinkThptsNeg, totalLinkGoodptsNeg, totalLinkCollPerNeg, totalLinkThptsPos, totalLinkGoodptsPos, totalLinkCollPerPos, linkLens, toWritePath, [setUpTitle, ' link 1 - Mean of ', int2str(numSims), ' simulations'], dataRate);

    
end

