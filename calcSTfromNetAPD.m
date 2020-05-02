function [slotTime] = calcSTfromNetAPD(linkLens, factor)
    %calculates the slotTime value which depends on the max. APD of the 
    %network; assume linkLens are given in KMs!
    %   slotTime = [factor]*[max. APD] (in seconds)

    c = 299704644.54; % light speed in air in m/sec, CONSTANT
    APD = (linkLens*1000)/c; % air propagation delay in seconds, a matrix of APDs according to the distances between the devices - APD for devices i and j can be found in cell [i, j] in the array
    maxAPD = max(APD(1, :)); % we have all of the distances in each line, so pick line 1 for instance
    slotTime = factor*maxAPD;
    
end

