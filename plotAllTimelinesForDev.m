function [] = plotAllTimelinesForDev(dev, events, simTime, totalNumDevs, resultsPath)
    %plots all the timelines for a specific device
    %   including TRAN and REC events

    figure(1)
    % first, TRAN events:
    tranEvents = extractEvents(dev, eventType.TRAN, events);
    plotEventsTimeLine(dev, eventType.TRAN, tranEvents, simTime, totalNumDevs);
    savefig([resultsPath, '\Transmission_Intervals.fig']);
    hold off

    figure(2)
    % second, REC events:
    recEvents = extractEvents(dev, eventType.REC, events);
    plotEventsTimeLine(dev, eventType.REC, recEvents, simTime, totalNumDevs);
    savefig([resultsPath, '\Reception_Intervals.fig']);
    hold off

end

