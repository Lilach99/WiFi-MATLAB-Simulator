function [] = plotLinkMetricsForDifferentSTs(linkThpts, linkGoodpts, linkCollPer, linkLens, resultsPath, setUpTitle)
    %gets a DS of linkInfo structs of a specific link, in different lengths, 
    %and plots some comerative graphs between the standard ST and APD-based
    %STs - total of 6 different values
  
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
    title({'Link Throughputs (including overhead)', 'Standard SlotTime VS various APD-based SlotTime values', setUpTitle});    
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    hold off
    
    nexttile
    % plot all goodputs graphs in the same figure
    for j=1:6
        scatter(linkLens, linkGoodpts(j, :), '.', colors{j});
        hold on
    end
    title({'Link Goodputs (only successfully received data)', 'Standard SlotTime VS APD-based SlotTime', setUpTitle});
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
    title({'Percentage of collided data bytes (%)', setUpTitle});
    xlabel('Link length (km)');
    ylabel('Percentage of collided data bytes (%)');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    savefig([resultsPath, '\Collided_Bytes_Percentage.fig']);
    hold off
    
end

