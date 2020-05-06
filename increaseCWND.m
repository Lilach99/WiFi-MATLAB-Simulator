function [curCWND] = increaseCWND(curCWND, maxCWND, backoffTech)
    %gets a curCWND and maxCWND and a backoff technique (enum),
    %and increases the curCWND according to the given technique
    
    switch backoffTech
        case {backoffTechnique.WIFI, backoffTechnique.MUL_INC_ADD_DEC, backoffTechnique.MUL_INC_MUL_DEC}
            % multiply by 2,with truncation to maxCWND
            curCWND = min(curCWND * 2, maxCWND);
            
        case {backoffTechnique.ADD_INC_MUL_DEC, backoffTechnique.ADD_INC_ADD_DEC}
            % add 2, with truncation to maxCWND
            curCWND = min(curCWND + 2, maxCWND);
            
        otherwise
            fprintf('illegal backoff technique!'); 
    end
    
end

