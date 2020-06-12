function [] = plotLinkMetricsForDifferentSTsAvgWithErrorbar(linkThpts, linkGoodpts, linkCollPer, linkThptsNeg, linkGoodptsNeg, linkCollPerNeg, linkThptsPos, linkGoodptsPos, linkCollPerPos, linkLens, resultsPath, setUpTitle, dataRate)
    %plots the avg scatter of the results
   
    % -1 is for srandard value
    slotTimeFactors = [-1, 2, 3, 1, 0.5, 0.25];
    
    figure(1)
    
    %colors = {'g', 'r', 'b', 'm', 'y', 'k'};
    colorsNames = {'green', 'red', 'blue', 'magenta', 'yellow', 'black'};
    tiledlayout(2,1)
    nexttile
    % plot all throughput graphs in the same figure
    for j=1:6
        errorbar(linkLens, linkThpts(j, :), linkThptsNeg(j, :), linkThptsPos(j, :),  '-o', 'Color', colorsNames{j});
%         scatter(linkLens, linkThpts(j, :), '.', colors{j});
%         line(linkLens, linkThpts(j, :), 'Color', colorsNames{j});
        hold on
    end
    xlabel('Link length (km)');
    ylabel('Average Link Throughput (Mbps)');
    ylim([0 4*dataRate]);
    title({'Average Link Throughputs (including overhead)', 'Standard SlotTime VS various APD-based SlotTime values', setUpTitle});    
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location', 'bestoutside');
    hold off
    
    nexttile
    % plot all goodputs graphs in the same figure
    for j=1:6
        % first, calculate the maximal data rate we could have in each distance
        maxDataRates = calcMaxDataRate(1460, linkLens, 6*10^6, slotTimeFactors(j));
       
        errorbar(linkLens, linkGoodpts(j, :),  linkGoodptsNeg(j, :), linkGoodptsPos(j, :), '-o', 'Color', colorsNames{j});
        hold on
        plot(linkLens, maxDataRates, '--', 'Color', colorsNames{j}); % also plot the max DR we can reach, for comparison
        
%         scatter(linkLens, linkGoodpts(j, :), '.', colors{j});
%         line(linkLens, linkGoodpts(j, :), 'Color', colorsNames{j});
        hold on
    end
    title({'Average Link Goodputs (only successfully received data) with ideal (maximum) data rate lines', 'Standard SlotTime VS APD-based SlotTime', setUpTitle});
    xlabel('Link length (km)');
    ylabel('Average Link Goodput (Mbps)');
    ylim([0 6]);
    legend({'Standard SlotTime', 'Max Data Rate for Standard SlotTime', '2APD SlotTime', 'Max Data Rate for 2APD SlotTime', '3APD SlotTime', 'Max Data Rate for 3APD SlotTime', 'APD SlotTime', 'Max Data Rate for APD SlotTime', '0.5APD SlotTime', 'Max Data Rate for 0.5APD SlotTime','0.25APD SlotTime', 'Max Data Rate for 0.25APD SlotTime'}, 'Location', 'bestoutside');
    savefig([resultsPath, '\Goodput_and_Throughput_AVG.fig']);
    hold off
        

    figure(2)   
    clf
    % plot all collided percisions graphs in the same figure
    for j=1:6
        errorbar(linkLens, linkCollPer(j, :), linkCollPerNeg(j, :), linkCollPerPos(j, :), '-o', 'Color', colorsNames{j});
%         scatter(linkLens, linkCollPer(j, :), '.', colors{j});
%         line(linkLens, linkCollPer(j, :), 'Color', colorsNames{j});
        hold on
    end
    title({'Average Percentage of collided data bytes (%)', setUpTitle});
    xlabel('Link length (km)');
    ylabel('Average Percentage of collided data bytes (%)');
    legend({'Standard SlotTime', '2APD SlotTime', '3APD SlotTime', 'APD SlotTime', '0.5APD SlotTime', '0.25APD SlotTime'}, 'Location', 'bestoutside');
    savefig([resultsPath, '\Collided_Bytes_Percentage_AVG.fig']);
    hold off
    
end

