classdef packetType < Simulink.IntEnumType
    enumeration
    ACK(1),
    DATA(2),
    NONE(100) % to avoid duplications
    end
end