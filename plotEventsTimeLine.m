function [] = plotEventsTimeLine(station, type, desEvents, simTime, totalNumDevs)
    %gets the needed info and plots the transmit/receive intervals of the
    %device
    %   assume simTime is given in seconds

    eventsTimes = cell2mat(cellfun(@(s)s.time, desEvents,'uni',0));
    eventTypesEnums = cellfun(@(s)s.type, desEvents,'uni',0);
    eventData = cell2mat(cellfun(@(s)double(s), eventTypesEnums,'uni',0)); 
    timeLine = zeros(simTime*10^6, 1);
    times = linspace(0, simTime*10^6, simTime*10^6);

    switch type
        
        case eventType.TRAN
            % take the TRAN_START and TRAN_END times, in microseconds
            % resolution (we apply rounding to avoid fractions)
            startEvesTimes = round(10^6*(eventsTimes(eventData == 6)), 0); % TRAN_START enum = 6
            endEvesTimes = round(10^6*(eventsTimes(eventData == 7)), 0); % TRAN_END enum = 7
            % the last TRAN events might happen after simTime but still
            % be recorded, so if discard it if there's a need:
            if(startEvesTimes(size(startEvesTimes, 2)) > simTime*10^6)
                startEvesTimes = startEvesTimes(1:(size(startEvesTimes, 2)-1));
            end
            % same for end events
            if(endEvesTimes(size(endEvesTimes, 2)) > simTime*10^6)
                endEvesTimes = endEvesTimes(1:(size(endEvesTimes, 2)-1));
            end

            timeLine(startEvesTimes) = 1; % put 1 in every TRAN_START cell
            timeLine(endEvesTimes) = -1; % put 1 in every TRAN_START cell
            timeLine = cumsum(timeLine);
            
            tranTimes = times(timeLine == 1);
            tranData = ones(size(tranTimes));
%             noTranTimes = times(timeLine == 0);
%             noTranData = ones(size(noTranTimes));

            % now, start plotting:
            scatter(tranTimes, tranData,  '.', 'd');
            % xticks(linspace(0, 5, 5*10^6));
            title(['Device number ', num2str(station) ' - transmitting intervals']);
%             hold on
%             scatter(noTranTimes, noTranData, '.', 'w');
            
            
        case eventType.REC
            % take the REC_START and REC_END times, in microseconds
            % resolution (we apply rounding to avoid fractions)
%             startEvesTimes = round(10^6*(eventsTimes(eventData == 2)), 0); % 
%             % the last REC_START event might happen after simTime but still
%             % be recorded, so if discard it if there's a need:
%             if(startEvesTimes(size(startEvesTimes, 2)) > simTime*10^6)
%                 startEvesTimes = startEvesTimes(1:(size(startEvesTimes, 2)-1));
%             end
%             endEvesTimes = round(10^6*(eventsTimes(eventData == 3)), 0); 
%             % same for endEvesTimes
%             if(endEvesTimes(size(endEvesTimes, 2)) > simTime*10^6)
%                 endEvesTimes = endEvesTimes(1:(size(endEvesTimes, 2)-1));
%             end
%             timeLine(endEvesTimes) = -1; % put -1 in every REC_END cell
%             timeLine(startEvesTimes) = 1; % put 1 in every REC_START cell
%             timeLine = cumsum(timeLine);
%             recTimes = times(timeLine > 0); % should be > 0 rather than == 1, because it could be that there will be muliple reeptions simultaneously
%             recData = ones(size(recTimes));
            
            eventPkts = (cellfun(@(s)s.pkt, desEvents,'uni',0)); % extract also the packets, to distinguish between MED events and own REC events
            eventPktsDsts = cell2mat(cellfun(@(s)s.dst, eventPkts, 'uni', 0));
            
            % REC events of packets destined to the device 'station'
            ourPktsEvesStartTimes = round(10^6*(eventsTimes(eventPktsDsts == station & eventData == 2))); % only packets for us, REC_START enum = 2           
            ourPktsEvesEndTimes = round(10^6*(eventsTimes(eventPktsDsts == station & eventData == 3))); % only packets for us, REC_END enum = 3
            % the last REC_START event might happen after simTime but still
            % be recorded, so if discard it if there's a need:
            if(ourPktsEvesStartTimes(size(ourPktsEvesStartTimes, 2)) > simTime*10^6)
                ourPktsEvesStartTimes = ourPktsEvesStartTimes(1:(size(ourPktsEvesStartTimes, 2)-1));
            end
            % same for ourPktsEvesEndTimes
            if(ourPktsEvesEndTimes(size(ourPktsEvesEndTimes, 2)) > simTime*10^6)
                ourPktsEvesEndTimes = ourPktsEvesEndTimes(1:(size(ourPktsEvesEndTimes, 2)-1));
            end
            ourTimeLine = zeros(simTime*10^6, 1);
            ourTimeLine(ourPktsEvesEndTimes) = -1; % put -1 in every REC_END cell
            ourTimeLine(ourPktsEvesStartTimes) = 1; % put 1 in every REC_START cell
            ourTimeLine = cumsum(ourTimeLine);
            ourRecTimes = times(ourTimeLine == 1);
            ourRecData = ones(size(ourRecTimes));
           
            tiledlayout(2,1) % we will plot the receiving intervals of our packets, as well as other device's packets
            % Top plot - all receiving intervals
%             nexttile
%             scatter(recTimes, recData,  '.', 'g');
%             title(['Device number ', num2str(station) ' - receiving intervals - total']);
% %             hold on
% %             scatter(ourPktsEvesEndTimes,ourPktsEvesEndData, '>', 'm');
               
            % Middle plot - only packets for us receiving intervals
            nexttile
            scatter(ourRecTimes, ourRecData,  '.', 'm');
            title(['Device number ', num2str(station) ' - receiving intervals of packets destined to it']);
%             hold on
%             scatter(endEvesTimes,endEvesData, '>', 'm');

            % Bottom plot
            nexttile
            for index=1:totalNumDevs
                if(index~=station)
                    % REC events of packets not destined to the device 'station'
                    otherPktsEvesStartTimes = round(10^6*(eventsTimes(eventPktsDsts == index & eventData == 2))); % only packets which are NOT for us, REC_START enum = 2           
                    otherPktsEvesEndTimes = round(10^6*(eventsTimes(eventPktsDsts == index & eventData == 3))); % only packets which are NOT for us, REC_END enum = 3
                    if(size(otherPktsEvesStartTimes, 2) == 0)
                        continue;
                    end
                    if(size(otherPktsEvesStartTimes, 2) > 0)
                        % the last REC_START event might happen after simTime but still
                        % be recorded, so if discard it if there's a need:
                        if(otherPktsEvesStartTimes(size(otherPktsEvesStartTimes, 2)) > simTime*10^6)
                            otherPktsEvesStartTimes = otherPktsEvesStartTimes(1:(size(otherPktsEvesStartTimes, 2)-1));
                        end
                    end
                    if(size(otherPktsEvesEndTimes, 2) > 0)
                        % same for ourPktsEvesEndTimes
                        if(otherPktsEvesEndTimes(size(otherPktsEvesEndTimes, 2)) > simTime*10^6)
                            otherPktsEvesEndTimes = otherPktsEvesEndTimes(1:(size(otherPktsEvesEndTimes, 2)-1));
                        end
                    end
                    
                    otherTimeLine = zeros(simTime*10^6, 1);
                    otherTimeLine(otherPktsEvesEndTimes) = -1; % put -1 in every REC_END cell
                    otherTimeLine(otherPktsEvesStartTimes) = 1; % put 1 in every REC_START cell
                    otherTimeLine = cumsum(otherTimeLine);
                    ourMedTimes = times(otherTimeLine > 0); % should be > 0 rather than == 1, because it could be that there will be muliple reeptions simultaneously
                    ourMedData = ones(size(ourMedTimes));
                    scatter(ourMedTimes, ourMedData,  '.', 'r');
                    hold on
                end
            end
            title(['Device number ', num2str(station) ' - medium busy intervals']);
            hold off

        otherwise
            fprinf('illegal event type to plot!');
    end

    

end

