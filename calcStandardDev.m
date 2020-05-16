function [totalLinkThptsSTDEV, totalLinkGoodptsSTDEV, totalLinkCollPerSTDEV] = calcStandardDev(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, numSTVals, numDists)
    %calculates the standard deviation values of the given results (3D to 2D)
    
    totalLinkThptsSTDEV = reshape(std(totalLinkThpts, [], 1), [numSTVals, numDists]);
    totalLinkGoodptsSTDEV = reshape(std(totalLinkGoodpts, [], 1), [numSTVals, numDists]);
    totalLinkCollPerSTDEV = reshape(std(totalLinkCollPer, [], 1), [numSTVals, numDists]);
    
end

