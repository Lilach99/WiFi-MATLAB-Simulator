function [linkThpts, linkGoodpts, linkCollPer] = calcLinkMetricsDifferentSTs(linkInfoStandardST, linkInfo3APDST, linkInfo2APDST, linkInfoAPDST, linkInfoHalfAPDST, linkInfoQrtAPDST, simTime, numSTVals, numDists)
    %calculates the link metrics of different ST results
    
    linkThpts = zeros(numSTVals, numDists);
    linkGoodpts = zeros(numSTVals, numDists);
    linkCollPer = zeros(numSTVals, numDists); % percentage of collided bytes
    
    % links with standard ST
    for i=1:size(linkInfoStandardST, 1)
        % calculate the link effective throughput and goodput (successfully
        % received bytes) for each link length
        linkThpts(1, i) = (8*(linkInfoStandardST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - bruto, including overhead from retransmissions!
        linkGoodpts(1, i) = (8*(linkInfoStandardST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkCollPer(1, i) = 100*(linkInfoStandardST{i}.dataCollCtr/linkInfoStandardST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    % links with APD-based ST
    % 2APD
    for i=1:size(linkInfo2APDST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkThpts(2, i) = (8*(linkInfo2APDST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - neto, without retransmissions!
        linkGoodpts(2, i) = (8*(linkInfo2APDST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkCollPer(2, i) = 100*(linkInfo2APDST{i}.dataCollCtr/linkInfo2APDST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    % 3APD
    for i=1:size(linkInfo3APDST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkThpts(3, i) = (8*(linkInfo3APDST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - neto, without retransmissions!
        linkGoodpts(3, i) = (8*(linkInfo3APDST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkCollPer(3, i) = 100*(linkInfo3APDST{i}.dataCollCtr/linkInfo3APDST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    % APD
    for i=1:size(linkInfoAPDST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkThpts(4, i) = (8*(linkInfoAPDST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - neto, without retransmissions!
        linkGoodpts(4, i) = (8*(linkInfoAPDST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkCollPer(4, i) = 100*(linkInfoAPDST{i}.dataCollCtr/linkInfoAPDST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    % half APD (1/2)
    for i=1:size(linkInfoHalfAPDST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkThpts(5, i) = (8*(linkInfoHalfAPDST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - neto, without retransmissions!
        linkGoodpts(5, i) = (8*(linkInfoHalfAPDST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkCollPer(5, i) = 100*(linkInfoHalfAPDST{i}.dataCollCtr/linkInfoHalfAPDST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    % quarter APD (1/4)
    for i=1:size(linkInfoQrtAPDST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkThpts(6, i) = (8*(linkInfoQrtAPDST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - neto, without retransmissions!
        linkGoodpts(6, i) = (8*(linkInfoQrtAPDST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkCollPer(6, i) = 100*(linkInfoQrtAPDST{i}.dataCollCtr/linkInfoQrtAPDST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
end

