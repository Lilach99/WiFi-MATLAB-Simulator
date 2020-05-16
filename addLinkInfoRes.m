function [totalLinkThpts, totalLinkGoodpts, totalLinkCollPer] = addLinkInfoRes(totalLinkThpts, totalLinkGoodpts, totalLinkCollPer, linkThpts, linkGoodpts, linkCollPer, simInd, numSTVals)
% add the results to the commulative results - for averaging later

    for i=1:numSTVals
        totalLinkThpts(simInd, :, i) = linkThpts(i, :);
        totalLinkGoodpts(simInd, :, i) = linkGoodpts(i, :);
        totalLinkCollPer(simInd, :, i) = linkCollPer(i, :);
    end

end

