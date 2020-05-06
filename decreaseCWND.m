function [curCWND] = decreaseCWND(curCWND, minCWND, backoffTech)
    %gets a curCWND and minCWND and a backoff technique (enum),
    %and decreases the curCWND according to the given technique
    
    switch backoffTech
        case backoffTechnique.WIFI
            % reset to minCWND
            curCWND = minCWND;
            
        case {backoffTechnique.MUL_INC_ADD_DEC, backoffTechnique.ADD_INC_ADD_DEC}
            % subtract 2, with truncation to minCWND
            curCWND = max(minCWND, curCWND - 2);

        case {backoffTechnique.ADD_INC_MUL_DEC, backoffTechnique.MUL_INC_MUL_DEC}
           % ddivide by 2, with truncation to minCWND
            curCWND = max(minCWND, curCWND / 2);
            
        otherwise
            fprintf('illegal backoff technique!');   
    end
    
end

