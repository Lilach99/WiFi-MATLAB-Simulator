 % creates a mapping between devices' events names and numbers:
classdef simEventType < Simulink.IntEnumType
    enumeration
    START_SIM(1),
    END_SIM(2),
    GEN_PACK(3),
    MED_BUSY(4),
    MED_FREE(5),
    SET_TIMER(6),
    CLEAR_TIMER(7),
    TRAN_START(8),
    TRAN_END(9),
    REC_START(11),
    REC_END(12),
    COLL_INC(13)
    end
end