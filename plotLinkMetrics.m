function [] = plotLinkMetrics(linkInfoStandardST, linkInfoAPDST, linkLens, simTime, resultsPath)
    %gets a DS of linkInfo structs of a specific link, in different lengths, 
    %and plots some comerative graphs between the standard ST and APD-based ST 
    
    linkSTThpts = zeros(1, size(linkLens, 2));
    linkSTGoodpts = zeros(1, size(linkLens, 2));
    linkSTCollPer = zeros(1, size(linkLens, 2)); % percentage of collided bytes
    linkAPDThpts = zeros(1, size(linkLens, 2));
    linkAPDGoodpts = zeros(1, size(linkLens, 2));
    linkAPDCollPer = zeros(1, size(linkLens, 2));
    
    % links with standard ST
    for i=1:size(linkInfoStandardST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkSTThpts(i) = (8*(linkInfoStandardST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - bruto, including overhead from retransmissions!
        linkSTGoodpts(i) = (8*(linkInfoStandardST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkSTCollPer(i) = 100*(linkInfoStandardST{i}.dataCollCtr/linkInfoStandardST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    % links with APD-based ST
    for i=1:size(linkInfoAPDST, 1)
        % calculate the link effective throuput and goodput (successfully
        % received bytes) for each link length
        linkAPDThpts(i) = (8*(linkInfoAPDST{i}.dataTranBruto)/simTime)/(10^6); % thpt in Mbps - neto, without retransmissions!
        linkAPDGoodpts(i) = (8*(linkInfoAPDST{i}.dataRecNeto)/simTime)/(10^6); % goodput in Mbps
        linkAPDCollPer(i) = 100*(linkInfoAPDST{i}.dataCollCtr/linkInfoAPDST{i}.dataTranBruto); % collided to transmitted ratio
    end
    
    figure(1)
    
    tiledlayout(2,1)
    nexttile
    % plot both throughput graphs in the same figure
    scatter(linkLens, linkSTThpts,  '.', 'd');
    title('Link Throughputs (including overhead) - Standard SlotTime VS APD-based SlotTime');
    xlabel('Link length (km)');
    ylabel('Link Throughput (Mbps)');
    hold on
    scatter(linkLens, linkAPDThpts,  '.', 'r');
    legend({'Standard SlotTime','APD-based SlotTime'},'Location','southwest');
    hold off
    nexttile
    % plot both throughput graphs in the same figure
    scatter(linkLens, linkSTGoodpts,  '.', 'd');
    title('Link Goodputs (only successfully received data)- Standard SlotTime VS APD-based SlotTime');
    xlabel('Link length (km)');
    ylabel('Link Goodput (Mbps)');
    hold on
    scatter(linkLens, linkAPDGoodpts,  '.', 'r');
    legend({'Standard SlotTime','APD-based SlotTime'},'Location','southwest');
    saveas(figure(1), strcat(resultsPath, '\Goodput_and_Throughput'), 'fig');
    hold off
        
    figure(2)   
    % plot both collided percisions graphs in the same figure
    scatter(linkLens, linkSTCollPer,  '.', 'd');
    title('Percentage of collided data bytes (%)');
    xlabel('Link length (km)');
    ylabel('Percentage of collided data bytes (%)');
    hold on
    scatter(linkLens, linkAPDCollPer,  '.', 'r');
    legend({'Standard SlotTime','APD-based SlotTime'},'Location','southwest');
    saveas(figure(2), strcat(resultsPath,'\Collided_Bytes_Percentage'), 'fig');
    hold off
    
end

