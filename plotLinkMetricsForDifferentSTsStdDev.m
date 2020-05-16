function [] = plotLinkMetricsForDifferentSTsStdDev(linkThpts, linkGoodpts, linkCollPer, linkLens, resultsPath, setUpTitle)
    %plots the standard deviation scatter of the results
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
    ylabel('Standard Deviation of Link Throughput');
    title({'Standard Deviation of Link Throughputs (including overhead)', 'Standard SlotTime VS various APD-based SlotTime values', setUpTitle});    
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    hold off
    
    nexttile
    % plot all goodputs graphs in the same figure
    for j=1:6
        scatter(linkLens, linkGoodpts(j, :), '.', colors{j});
        hold on
    end
    title({'Standard Deviation of Link Goodputs (only successfully received data)', 'Standard SlotTime VS APD-based SlotTime', setUpTitle});
    xlabel('Link length (km)');
    ylabel('Standard Deviation of Link Goodput');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    savefig([resultsPath, '\Goodput_and_Throughput_STDDEV.fig']);
    hold off
        
    figure(2)   
    % plot all collided percisions graphs in the same figure
    for j=1:6
        scatter(linkLens, linkCollPer(j, :), '.', colors{j});
        hold on
    end
    title({'Standard Deviation of Percentage of collided data bytes (%)', setUpTitle});
    xlabel('Link length (km)');
    ylabel('Standard Deviation of Percentage of collided data bytes');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location','southwest');
    savefig([resultsPath, '\Collided_Bytes_Percentage_STDDEV.fig']);
    hold off
    
end

