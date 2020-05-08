function [] = saveResults(simOutput, numDevs, path)
    %gets a simulation output and saves in to a .mat file in the corresponding
    %directory
    
%     linksInfo = simOutput.linksRes;
%     save(path, '-struct', 'linksInfo');
%     packetsInfo = simOutput.packetsDS;
%     save(path, '-struct', 'packetsInfo');
%     eventsInfo = simOutput.eventsDS;
%     save(path, '-struct', 'eventsInfo');

    collDataBytesCtr = 0;
    collCtrlBytesCtr = 0;
    for p=1:numDevs
        collDataBytesCtr = collDataBytesCtr + simOutput.linksRes{p}.dataCollCtr;
        collCtrlBytesCtr = collCtrlBytesCtr + simOutput.linksRes{p}.ctrlCollCtr;
    end
    simOutput.totalCollDataBytesCtr = collDataBytesCtr/10^3; % in KBs
    simOutput.totalCollCtrlBytesCtr = collCtrlBytesCtr/10^3; % in KBs
    
    save([path, '/simulation_output'], '-struct', 'simOutput');
    
end

