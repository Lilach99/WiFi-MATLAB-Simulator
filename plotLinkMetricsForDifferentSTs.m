function [] = plotLinkMetricsForDifferentSTs(linkInfoStandardST, linkInfo3APDST, linkInfo2APDST, linkInfoAPDST, linkInfoHalfAPDST, linkInfoQrtAPDST, linkLens, simTime, resultsPath)
    %gets a DS of linkInfo structs of a specific link, in different lengths, 
    %and plots some comerative graphs between the standard ST and APD-based
    %STs - total of 6 different values
    
    linkThpts = zeros(6, size(linkLens, 2));
    linkGoodpts = zeros(6, size(linkLens, 2));
    linkCollPer = zeros(6, size(linkLens, 2)); % percentage of collided bytes
    
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
    
    figure(1)
    
    colors = {'g', 'r', 'b', 'm', 'y', 'k'};
    tiledlayout(2,1)
    nexttile
    % plot all throughput graphs in the same figure
    for j=1:6
        scatter(linkLens, linkThpts(j, :), '.', colors{j});
        hold on
    end
    xlabel('Link length (km)');
    ylabel('Link Throughput (Mbps)');
    title('Link Throughputs (including overhead) - Standard SlotTime VS various APD-based SlotTime values');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    hold off
    
    nexttile
    % plot all goodputs graphs in the same figure
    for j=1:6
        scatter(linkLens, linkGoodpts(j, :), '.', colors{j});
        hold on
    end
    title('Link Goodputs (only successfully received data)- Standard SlotTime VS APD-based SlotTime');
    xlabel('Link length (km)');
    ylabel('Link Goodput (Mbps)');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    savefig([resultsPath, '\Goodput_and_Throughput.fig']);
    hold off
        
    figure(2)   
    % plot all collided percisions graphs in the same figure
    for j=1:6
        scatter(linkLens, linkCollPer(j, :), '.', colors{j});
        hold on
    end
    title('Percentage of collided data bytes (%)');
    xlabel('Link length (km)');
    ylabel('Percentage of collided data bytes (%)');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    savefig([resultsPath, '\Collided_Bytes_Percentage.fig']);
    hold off
    
end

