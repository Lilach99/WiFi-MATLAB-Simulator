function [] = simulateDifferentSTsInDataRate(dataRate, packetsPolicy, linkLens)

    p = gcp('nocreate');
    if (isempty(p))
        parpool(4);
    end

    % tests: 

    %[output]=simulateNet(9, 30, 2, 0, 0, 10);
    simTime = 60;
    numDevs = 2;
    numDists = size(linkLens, 2);
    numSTVals = 6;
    %linkLens = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]; % in kms!

    % DSs for future display of the metrics of the links:
    link1InfoStandardST = cell(numDists, 1);
    link2InfoStandardST = cell(numDists, 1);
    link1Info2APDST = cell(numDists, 1);
    link2Info2APDST = cell(numDists, 1);
    link1Info3APDST = cell(numDists, 1);
    link2Info3APDST = cell(numDists, 1);
    link1InfoAPDST = cell(numDists, 1);
    link2InfoAPDST = cell(numDists, 1);
    link1InfoHalfAPDST = cell(numDists, 1);
    link2InfoHalfAPDST = cell(numDists, 1);
    link1InfoQrtAPDST = cell(numDists, 1);
    link2InfoQrtAPDST = cell(numDists, 1);

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
    experimentResultsPath = ['Results\Experiment_Various_ST_Values_', pktPol, '_', int2str(dataRate), '_Mbps_data_rate_', int2str(numDevs/2), '_pTp_Links_', int2str(simTime), '_secondes_simulation_', t];
    mkdir(experimentResultsPath); % for this experiment
    % standardSTPath = [experimentResultsPath, '\Standard_ST'];
    % mkdir(standardSTPath); % standard ST
    % APDSTPath = [experimentResultsPath, '\2APD_ST'];
    % mkdir(APDSTPath); % 2APD ST
    % output arrays
    outputStandard = cell(numDists, 1);
    output2APD = cell(numDists, 1);
    output3APD = cell(numDists, 1);
    outputAPD = cell(numDists, 1);
    outputHalfAPD = cell(numDists, 1);
    outputQrtAPD = cell(numDists, 1);
tic
    %for h=1:numDists
    
    parfor h=1:numDists
      %dists = getLinksLenfor4Devs(h); % in KMs
      dists = linkLens(h)*[0, 1; 1, 0]; 
      %dists = getLinksLenfor6Devs(h); % in KMs
      ST = 10^-5+calcSTfromNetAPD(dists, 1); % 1 APD !
      disp(['Length of tested link: ', int2str(10*h)]);

      disp('Standard');
      % Standard ST experiment
      resPath = 'lala'; % not used, dummy!
      %mkdir(resPath);
      outputStandard{h} = simulateNet(9*10^-6, simTime, numDevs, 0, 0, linkLens(h), dataRate,  packetsPolicy, resPath); % the last parameter is dataRate in Mbps!
      link1InfoStandardST{h} = outputStandard{h}.linksRes{1};
      link2InfoStandardST{h} = outputStandard{h}.linksRes{2};

      disp('2APD');
      output2APD{h} = simulateNet(2*ST, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath);
      link1Info2APDST{h} = output2APD{h}.linksRes{1};
      link2Info2APDST{h} = output2APD{h}.linksRes{2};

      disp('3APD');
      output3APD{h} = simulateNet(3*ST, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath);
      link1Info3APDST{h} = output3APD{h}.linksRes{1};
      link2Info3APDST{h} = output3APD{h}.linksRes{2};

      disp('APD');
      outputAPD{h} = simulateNet(ST, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath);
      link1InfoAPDST{h} = outputAPD{h}.linksRes{1};
      link2InfoAPDST{h} = outputAPD{h}.linksRes{2};

      disp('0.5APD');
      outputHalfAPD{h} = simulateNet(0.5*ST, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath);
      link1InfoHalfAPDST{h} = outputHalfAPD{h}.linksRes{1};
      link2InfoHalfAPDST{h} = outputHalfAPD{h}.linksRes{2};

      disp('0.25APD');
      outputQrtAPD{h} = simulateNet(0.25*ST, simTime, numDevs, 0, 0, linkLens(h), dataRate, packetsPolicy, resPath);
      link1InfoQrtAPDST{h} = outputQrtAPD{h}.linksRes{1};
      link2InfoQrtAPDST{h} = outputQrtAPD{h}.linksRes{2};

    end
    toc

    linkInfoStandardST{1} = link1InfoStandardST;
    linkInfoStandardST{2} = link2InfoStandardST;

    linkInfo2APDST{1} = link1Info2APDST;
    linkInfo2APDST{2} = link2Info2APDST;

    linkInfo3APDST{1} = link1Info3APDST;
    linkInfo3APDST{2} = link2Info3APDST;

    linkInfoAPDST{1} = link1InfoAPDST;
    linkInfoAPDST{2} = link2InfoAPDST;

    linkInfoHalfAPDST{1} = link1InfoHalfAPDST;
    linkInfoHalfAPDST{2} = link2InfoHalfAPDST;

    linkInfoQrtAPDST{1} = link1InfoQrtAPDST;
    linkInfoQrtAPDST{2} = link2InfoQrtAPDST;

    setUpTitle = [int2str(numDevs), ' point to point link, 1460B packets, ', int2str(simTime), ' seconds simulation'];


    %tic
    for k=1:numDevs
        resultsPath = [experimentResultsPath, '\Link_', int2str(k)];
        mkdir(resultsPath);
        [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST{k}, linkInfo3APDST{k}, linkInfo2APDST{k}, linkInfoAPDST{k}, linkInfoHalfAPDST{k}, linkInfoQrtAPDST{k}, simTime, numSTVals, numDists);
        plotLinkMetricsForDifferentSTs(linkThpts, linkGoodpts, linkCollPer, linkLens, resultsPath, setUpTitle);
    end
    %toc

    save([experimentResultsPath, '\output_', t, '.mat']);

end

