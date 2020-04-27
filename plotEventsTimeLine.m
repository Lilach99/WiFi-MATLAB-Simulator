function [] = plotEventsTimeLine(station, type, desEvents)
%gets 
%   Detailed explanation goes here

    eventsTimes = cell2mat(cellfun(@(s)s.time, desEvents,'uni',0));
    eventTypesEnums = cellfun(@(s)s.type, desEvents,'uni',0);
    eventData = cell2mat(cellfun(@(s)double(s), eventTypesEnums,'uni',0)); 

    switch type
        
        case eventType.TRAN
            startEvesTimes = eventsTimes(eventData == 6); % TRAN_START enum = 6
            startEvesData = ones(size(startEvesTimes));
            endEvesTimes = eventsTimes(eventData == 7); % TRAN_END enum = 7
            endEvesData = ones(size(endEvesTimes));
            scatter(startEvesTimes, startEvesData,  '<', 'd');
            title(['Device number ', num2str(station) ' - transmitting intervals']);
            hold on
            scatter(endEvesTimes,endEvesData, '>', 'm');
            hold off

        case eventType.REC
            startEvesTimes = eventsTimes(eventData == 2); % REC_START enum = 2
            startEvesData = ones(size(startEvesTimes));
            endEvesTimes = eventsTimes(eventData == 3); % REC_END enum = 3
            endEvesData = ones(size(endEvesTimes));
            
            ourPktsEvesStartTimes = eventsTimes(eventData == 2 & desEvents.pkt.dst == station);
            ourPktsEvesStartData = ones(size(ourPktsEvesStartTimes));
            
            ourPktsEvesEndTimes = eventsTimes(eventData == 3 & desEvents.pkt.dst == station);
            ourPktsEvesEndData = ones(size(ourPktsEvesEndTimes));
            
            tiledlayout(3,1) % we will plot the receiving intervals of our packets, as well as other device's packets
            % Top plot - all receiving intervals
            nexttile
            scatter(ourPktsEvesStartTimes, ourPktsEvesStartData,  '<', 'd');
            title(['Device number ', num2str(station) ' - receiving intervals - total']);
            hold on
            scatter(ourPktsEvesEndTimes,ourPktsEvesEndData, '>', 'm');
            hold off
               
            % Middle plot - only packets for us receiving intervals
            nexttile
            scatter(startEvesTimes, startEvesData,  '<', 'd');
            title(['Device number ', num2str(station) ' - receiving intervals of packets destined to it']);
            hold on
            scatter(endEvesTimes,endEvesData, '>', 'm');
            hold off

            % Bottom plot
            nexttile
            title(['Device number ', num2str(station) ' - medium busy intervals']);


            
            
        otherwise
            fprinf('illegal event type to plot!');
    end

    

end

