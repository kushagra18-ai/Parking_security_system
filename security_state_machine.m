function [newState, alarmTriggered, eventMsg] = ...
    security_state_machine(currentState, threatScore, plateResult, simTime, alarmTriggered)
%SECURITY_STATE_MACHINE  Implements the vehicle security decision logic.
%
%  This function replicates the behaviour of a Stateflow chart.
%  States:
%    SecurityState.IDLE            - System armed, no detections
%    SecurityState.MONITORING      - Actor detected, assessing threat
%    SecurityState.THREAT_DETECTED - High suspicion, pre-alarm
%    SecurityState.ALARM           - Alarm triggered, locks engaged
%
%  Transitions:
%    IDLE         -> MONITORING      : numDet > 0
%    MONITORING   -> IDLE            : threatScore < 0.20
%    MONITORING   -> THREAT_DETECTED : threatScore >= 0.40
%    MONITORING   -> IDLE            : authorized plate detected
%    THREAT_DETECTED -> ALARM        : threatScore >= 0.70 for > 2 s
%    THREAT_DETECTED -> MONITORING   : threatScore drops below 0.40
%    ALARM        -> IDLE            : manual reset (simulated at t=28 s)

    persistent threatHighTimer;
    if isempty(threatHighTimer), threatHighTimer = 0; end

    newState  = currentState;
    eventMsg  = '';

    switch currentState

        %% ---- IDLE -----------------------------------------------
        case SecurityState.IDLE

            if threatScore > 0.15
                newState = SecurityState.MONITORING;
                eventMsg = sprintf('[%.1f s] STATE: IDLE -> MONITORING  (threatScore=%.2f)', ...
                                   simTime, threatScore);
            end

        %% ---- MONITORING -----------------------------------------
        case SecurityState.MONITORING

            % Authorized plate detected → relax
            if plateResult.detected && plateResult.authorized
                newState = SecurityState.IDLE;
                eventMsg = sprintf('[%.1f s] AUTHORIZED plate "%s" (%s) -> IDLE', ...
                                   simTime, plateResult.plateText, plateResult.ownerName);
                threatHighTimer = 0;
                return;
            end

            % Threat escalates
            if threatScore >= 0.40
                newState = SecurityState.THREAT_DETECTED;
                eventMsg = sprintf('[%.1f s] STATE: MONITORING -> THREAT_DETECTED  (threatScore=%.2f)', ...
                                   simTime, threatScore);

            % Threat recedes
            elseif threatScore < 0.20
                newState = SecurityState.IDLE;
                eventMsg = sprintf('[%.1f s] STATE: MONITORING -> IDLE  (threat receded)', simTime);
            end

        %% ---- THREAT_DETECTED ------------------------------------
        case SecurityState.THREAT_DETECTED

            if threatScore >= 0.70
                threatHighTimer = threatHighTimer + 0.1;   % +1 sample time

                if threatHighTimer >= 2.0   % 2 consecutive seconds above 0.70
                    newState = SecurityState.ALARM;
                    alarmTriggered = true;
                    eventMsg = sprintf('[%.1f s] *** ALARM TRIGGERED *** DOORS LOCKED | HORN ON (threatScore=%.2f)', ...
                                       simTime, threatScore);
                    threatHighTimer = 0;
                end

            elseif threatScore < 0.40
                newState = SecurityState.MONITORING;
                threatHighTimer = 0;
                eventMsg = sprintf('[%.1f s] STATE: THREAT_DETECTED -> MONITORING  (threat decreased)', simTime);
            end

        %% ---- ALARM ----------------------------------------------
        case SecurityState.ALARM

            % Simulate manual reset at t = 28 s (owner returns to vehicle)
            if simTime >= 28.0
                newState  = SecurityState.IDLE;
                alarmTriggered = false;
                threatHighTimer = 0;
                eventMsg = sprintf('[%.1f s] ALARM RESET by owner. System back to IDLE.', simTime);
            end
    end
end
