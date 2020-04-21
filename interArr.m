function [interArrTime] = interArr(pkt, linkInfo)
    %calculates the inter arrival time given the rate (in data bytes per
    %second) and the current packet lenght
    %   the formula is: IAT = 1/(DATA_RATE/PKT_LENGHT) (IAT is in seconds)
    
    interArrTime = 1/(linkInfo.dataRate/(pkt.length*8)); % note that we need units casting in the pkt.length - from bytes to bits!!
    
    
end