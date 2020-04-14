 % creates a mapping between devices' events names and numbers:
classdef devEventType < Simulink.IntEnumType
    enumeration
    PACKET_EXISTS(1),
    TRAN_END(2),
    REC_START(3),
    REC_END(4),
    TIMER_EXPIRED(5)
    end
end