classdef backoffTechnique < Simulink.IntEnumType
    % this enum is for backoff tehniques:
    % 1. 802.11 technique (multiplicative increase, reset decrease)
    % 2. Additive increase multiplicative decrease
    % 3. Additive increase additive decrease
    % 4. Multiplicative increase additive decrease
    % 5. Multiplicative increase multiplicative decrease

    enumeration
    WIFI(1),
    ADD_INC_MUL_DEC(2),
    ADD_INC_ADD_DEC(3),
    MUL_INC_ADD_DEC(4),
    MUL_INC_MUL_DEC(5)
    end
    
end