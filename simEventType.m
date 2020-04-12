 % creates a mapping between devices' events names and numbers:
classdef simEventType < Simulink.IntEnumType
    enumeration
    START_SIM(1),
    END_SIM(2),
    GEN_PACK(3),
    PACKET_IN_QUQUE(4),
    CHECK_QUEUE(5),
    MED_BUSY(6),
    MED_FREE(7),
    SET_TIMER(8),
    CLEAR_TIMER(9),
    TRAN_START(10),
    TRAN_END(11),
    REC_START(12),
    REC_END(13),
    COLL_INC(14),
    LOG_WRITE(15)
    end
end