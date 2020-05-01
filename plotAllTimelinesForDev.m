function [] = plotAllTimelinesForDev(dev, events, simTime, totalNumDevs)
    %plots all the timelines for a specific device
    %   including TRAN and REC events

    figure(1)
    % first, TRAN events:
    tranEvents = extractEvents(dev, eventType.TRAN, events);
    plotEventsTimeLine(dev, eventType.TRAN, tranEvents, simTime, totalNumDevs);
    saveas(figure(1), [pwd ['/ResultsGraphs/TranTimelineDev', int2str(dev)]]);

    figure(2)
    % second, REC events:
    recEvents = extractEvents(dev, eventType.REC, events);
    plotEventsTimeLine(dev, eventType.REC, recEvents, simTime, totalNumDevs);
    saveas(figure(2), [pwd ['/ResultsGraphs/RecTimelineDev', int2str(dev)]]);
    
end

