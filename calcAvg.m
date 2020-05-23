function [totalLinkThptsAVG, totalLinkGoodptsAVG, totalLinkCollPerAVG] = calcAvg(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, numSTVals, numDists)
    %calculates the mean values of the given results (3D to 2D)
    totalLinkThptsAVG = transpose(reshape(mean(totalLinkThpts, 1), [numDists, numSTVals]));
    totalLinkGoodptsAVG = transpose(reshape(mean(totalLinkGoodpts, 1), [numDists, numSTVals]));
    totalLinkCollPerAVG = transpose(reshape(mean(totalLinkCollPer, 1), [numDists, numSTVals]));
    
end

