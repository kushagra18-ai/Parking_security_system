function run_security_simulation(scenario, camera, whitelist)

    %% Initialise Dashboard Figure
    hFig = figure('Name', 'AI Vehicle Security Dashboard', ...
                  'NumberTitle', 'off', ...
                  'Position', [800 50 650 700], ...
                  'Color', [0.1 0.1 0.1]);

    axBEV = subplot(3,2,[1 2], 'Parent', hFig);
    title(axBEV, 'Bird''s Eye View', 'Color', 'w');
    set(axBEV, 'Color', [0.15 0.15 0.15], 'XColor','w', 'YColor','w');

    axCAM = subplot(3,2,[3 4], 'Parent', hFig);
    title(axCAM, 'Synthetic Camera Feed', 'Color', 'w');
    set(axCAM, 'Color', [0.15 0.15 0.15]);

    axSTATUS = subplot(3,2,[5 6], 'Parent', hFig);
    set(axSTATUS, 'Color',[0.15 0.15 0.15], 'XTick',[], 'YTick',[]);
    axis(axSTATUS, 'off');

    %% Security State Initialisation
    securityState  = SecurityState.IDLE;
    alarmTriggered = false;
    eventLog       = {};
    threatScores   = [];
    timeStamps     = [];
    simTime        = 0;
    frameCount     = 0;

    syntheticPlates  = {'UP16AB1234', 'UNKNOWN_99', 'DL01CD5678', 'XYZ_THREAT'};
    plateAppearTimes = [5, 12, 20, 26];

    %% Get ego actor handle (last actor added in build_scenario)
    egoActor = scenario.Actors(end);

    %% Main Simulation Loop
    while advance(scenario)

        simTime    = simTime + scenario.SampleTime;
        frameCount = frameCount + 1;

        %% Get poses of all OTHER actors relative to ego
        %  Correct syntax: targetPoses(egoActorHandle) — one argument only
        poses = targetPoses(egoActor);

        %% Generate synthetic detections from poses
        [detections, numDet] = generate_synthetic_detections(poses, simTime);

        %% AI Threat Classification
        [threatScore, threatLabel] = classify_threat(detections, numDet, simTime);
        threatScores(end+1) = threatScore;
        timeStamps(end+1)   = simTime;

        %% OCR License Plate Check
        plateResult = check_license_plate(simTime, plateAppearTimes, ...
                                          syntheticPlates, whitelist);

        %% Decision Logic (State Machine)
        [securityState, alarmTriggered, newEvent] = ...
            security_state_machine(securityState, threatScore, ...
                                   plateResult, simTime, alarmTriggered);
        if ~isempty(newEvent)
            eventLog{end+1} = newEvent;
        end

        %% Update Dashboard every 5 frames
        if mod(frameCount, 5) == 0
            update_dashboard(axBEV, axCAM, axSTATUS, scenario, ...
                             detections, threatScore, threatLabel, ...
                             plateResult, securityState, alarmTriggered, ...
                             timeStamps, threatScores, simTime);
        end

        drawnow limitrate;
    end

    %% Post-Simulation Threat Score Plot
    figure('Name','Threat Score Timeline','NumberTitle','off', ...
           'Color',[0.1 0.1 0.1]);
    plot(timeStamps, threatScores, 'c-', 'LineWidth', 1.5);
    hold on;
    yline(0.7, 'r--', 'Alarm Threshold (0.70)', 'LineWidth', 1.2);
    yline(0.4, 'y--', 'Alert Threshold (0.40)', 'LineWidth', 1.2);
    xlabel('Simulation Time (s)', 'Color','w');
    ylabel('Threat Score (0-1)',  'Color','w');
    title('AI Threat Score Over Time', 'Color','w');
    set(gca, 'Color',[0.15 0.15 0.15], 'XColor','w','YColor','w');
    ylim([0 1]); grid on; hold off;

    %% Print Event Log
    fprintf('\n--- SECURITY EVENT LOG ---\n');
    for i = 1:numel(eventLog)
        fprintf('  %s\n', eventLog{i});
    end
    fprintf('--------------------------\n');
end
