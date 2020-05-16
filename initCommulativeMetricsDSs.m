function [totalLinkThpts, totalLinkGoodpts, totalLinkCollPer] = initCommulativeMetricsDSs(numDists, numSTVals, numSims)
    %initialize the cimmulative results vectors
    
    totalLinkThpts = zeros(numSims, numDists, numSTVals);
    totalLinkGoodpts = zeros(numSims, numDists, numSTVals);
    totalLinkCollPer = zeros(numSims, numDists, numSTVals);
    
end

