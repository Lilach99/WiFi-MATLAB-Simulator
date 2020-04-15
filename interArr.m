function [interArrTime] = interArr(pkt, linkInfo)
    %calcculates the inter arrival time given the rate (in data bytes per
    %second) and the current packet lenght
    %   the formula is: IAT = 1/(DATA_RATE/PKT_LENGHT) (IAT is in seconds)
    
    interArrTime = 1/(linkInfo.dataRate/pkt.length); % note that we might need units casting here - maybe from Mbytes to bytes!!
    
    
end