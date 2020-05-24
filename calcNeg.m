function [totalLinkThptsNEG, totalLinkGoodptsNEG, totalLinkCollPerNEG] = calcNeg(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, numSTVals, numDists)
    %calculates the lower error bar values of the given results (3D to 2D)
    totalLinkThptsAVG = transpose(reshape(mean(totalLinkThpts, 1), [numDists, numSTVals]));
    totalLinkGoodptsAVG = transpose(reshape(mean(totalLinkGoodpts, 1), [numDists, numSTVals]));
    totalLinkCollPerAVG = transpose(reshape(mean(totalLinkCollPer, 1), [numDists, numSTVals]));
    
    totalLinkThptsNEG = transpose(reshape(min(totalLinkThpts, [], 1), [numDists, numSTVals]));
    totalLinkThptsNEG = totalLinkThptsAVG - totalLinkThptsNEG;
    totalLinkGoodptsNEG = transpose(reshape(min(totalLinkGoodpts, [], 1), [numDists, numSTVals]));
    totalLinkGoodptsNEG = totalLinkGoodptsAVG - totalLinkGoodptsNEG;
    totalLinkCollPerNEG = transpose(reshape(min(totalLinkCollPer, [], 1), [numDists, numSTVals]));
    totalLinkCollPerNEG = totalLinkCollPerAVG - totalLinkCollPerNEG;
    
end

