classdef devStateType < Simulink.IntEnumType
    enumeration
    IDLE(1),
    START_CSMA(2),
    TRAN_PACK(3),
    WAIT_FOR_ACK(4),
    REC_ACK(5),
    WAIT_FOR_IDLE(6),
    WAIT_DIFS(7),
    BACKING_OFF(8),
    REC_PACK(9),
    SEND_ACK(10)    
    end
end