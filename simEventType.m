 % creates a mapping between devices' events names and numbers:
classdef simEventType < Simulink.IntEnumType
    % the events are ordered according to their "importance" - meaning the
    % order in which we have to handle them
    % this is important, because some events effects the others if they
    % happen at the same time - like MED_BUSY and MED_FREE
    % START_SIM has to be done before anything else
    % END_SIM should be done last
    enumeration
    START_SIM(1),
    REC_START(2),
    REC_END(3),
    GEN_PACK(4),
    CLEAR_TIMER(5),
    TRAN_START(6),
    TRAN_END(7),
    SET_TIMER(8),
    COLL_INC(9),
    END_SIM(10)
    end
end