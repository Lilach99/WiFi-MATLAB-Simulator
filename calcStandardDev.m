function [totalLinkThptsSTDEV, totalLinkGoodptsSTDEV, totalLinkCollPerSTDEV] = calcStandardDev(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, numSTVals, numDists)
    %calculates the standard deviation values of the given results (3D to 2D)
    
    totalLinkThptsSTDEV = transpose(reshape(std(totalLinkThpts, [], 1), [numDists, numSTVals]));
    totalLinkGoodptsSTDEV = transpose(reshape(std(totalLinkGoodpts, [], 1), [numDists, numSTVals]));
    totalLinkCollPerSTDEV = transpose(reshape(std(totalLinkCollPer, [], 1), [numDists, numSTVals]));
    
end

