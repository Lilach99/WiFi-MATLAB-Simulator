function [totalLinkThptsAVG, totalLinkGoodptsAVG, totalLinkCollPerAVG] = calcAvg(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, numSTVals, numDists)
    %calculates the mean values of the given results (3D to 2D)
    
    totalLinkThptsAVG = reshape(mean(totalLinkThpts, 1), [numSTVals, numDists]);
    totalLinkGoodptsAVG = reshape(mean(totalLinkGoodpts, 1), [numSTVals, numDists]);
    totalLinkCollPerAVG = reshape(mean(totalLinkCollPer, 1), [numSTVals, numDists]);
    
end

