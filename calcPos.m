function [totalLinkThptsPOS, totalLinkGoodptsPOS, totalLinkCollPerPOS] = calcPos(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, numSTVals, numDists)
    %calculates the lower error bar values of the given results (3D to 2D)
    totalLinkThptsAVG = transpose(reshape(mean(totalLinkThpts, 1), [numDists, numSTVals]));
    totalLinkGoodptsAVG = transpose(reshape(mean(totalLinkGoodpts, 1), [numDists, numSTVals]));
    totalLinkCollPerAVG = transpose(reshape(mean(totalLinkCollPer, 1), [numDists, numSTVals]));
    
    totalLinkThptsPOS = transpose(reshape(max(totalLinkThpts, [], 1), [numDists, numSTVals]));
    totalLinkThptsPOS = totalLinkThptsPOS - totalLinkThptsAVG;
    totalLinkGoodptsPOS = transpose(reshape(max(totalLinkGoodpts, [], 1), [numDists, numSTVals]));
    totalLinkGoodptsPOS = totalLinkGoodptsPOS - totalLinkGoodptsAVG;
    totalLinkCollPerPOS = transpose(reshape(max(totalLinkCollPer, [], 1), [numDists, numSTVals]));
    totalLinkCollPerPOS = totalLinkCollPerPOS - totalLinkCollPerAVG;
    
end

