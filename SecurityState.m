classdef SecurityState
%SECURITYSTATE  Enumeration of security system states.
%
%  Used by security_state_machine.m to represent the Stateflow chart states.

    enumeration
        IDLE
        MONITORING
        THREAT_DETECTED
        ALARM
    end
end
