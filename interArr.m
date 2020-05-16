function [interArrTime] = interArr(pkt, linkInfo)
    %calculates the inter arrival time given the rate (in data bytes per
    %second) and the current packet lenght
    %   the formula is: IAT = 1/(DATA_RATE/PKT_LENGHT) (IAT is in seconds)
    
    interArrTime = 1/(linkInfo.dataRate/(pkt.length*8)); % in seconds; note that we need units casting in the pkt.length - from bytes to bits!!
    
    % we should enter some randomness to the link so we
    % add/subtract between 0%-20% from the interArrTime we got
    r = rand;
    per = (rand/5)*interArrTime; % take a part from interArrTime, between 0%-20%
    if(r > 0.5)
        % add
        interArrTime = interArrTime + per;
    else
        % subtruct
        interArrTime = interArrTime - per;
    end
    
end