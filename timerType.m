 % creates a mapping between timer types and numbers:
classdef timerType < Simulink.IntEnumType
    enumeration
    DIFS(1),
    BACKOFF(2),
    ACK(3),
    NONE(4)
    end
end