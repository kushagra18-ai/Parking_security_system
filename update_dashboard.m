function update_dashboard(axBEV, axCAM, axSTATUS, scenario, ...
                          detections, threatScore, threatLabel, ...
                          plateResult, securityState, alarmTriggered, ...
                          timeStamps, threatScores, simTime)
%UPDATE_DASHBOARD  Refreshes all three dashboard panels each render cycle.
%
%  Panels:
%    axBEV    - Bird's Eye View of the parking lot scenario
%    axCAM    - Synthetic camera frame with bounding boxes (insertObjectAnnotation style)
%    axSTATUS - Text-based security status readout

    %% ----- Panel 1 : Bird's Eye View --------------------------------
    axes(axBEV);
    cla(axBEV);
    try
        plot(scenario);
    catch
        % plot(scenario) requires Automated Driving Toolbox; fallback:
        text(0.5, 0.5, 'Scenario View (requires ADT)', ...
             'HorizontalAlignment','center','Color','w','Parent',axBEV);
    end
    title(axBEV, sprintf('Bird''s Eye View  [t = %.1f s]', simTime), 'Color','w');
    set(axBEV,'Color',[0.15 0.15 0.15],'XColor','w','YColor','w');

    %% ----- Panel 2 : Synthetic Camera Frame (640 x 480) -------------
    axes(axCAM);
    cla(axCAM);

    % Black "image" background
    img = zeros(480, 640, 3, 'uint8');

    % Draw simulated road lines
    img(230:250, :, 3) = 60;    % faint blue road lane

    %% Overlay bounding boxes (replicates insertObjectAnnotation)
    colourMap = struct('SAFE',      [0,   255, 0  ], ...
                       'SUSPICIOUS',[255, 165, 0  ], ...
                       'INTRUDER',  [255, 0,   0  ]);
    boxColour = colourMap.(threatLabel);

    for i = 1:numel(detections)
        bb = round(detections(i).BoundingBox);  % [x y w h]
        x1 = max(1, bb(1)); y1 = max(1, bb(2));
        x2 = min(640, bb(1)+bb(3)); y2 = min(480, bb(2)+bb(4));
        if x1>=x2 || y1>=y2, continue; end

        % Draw rectangle (top & bottom rows, left & right columns)
        img(y1:y1+2,   x1:x2, 1) = boxColour(1);
        img(y1:y1+2,   x1:x2, 2) = boxColour(2);
        img(y1:y1+2,   x1:x2, 3) = boxColour(3);
        img(y2-2:y2,   x1:x2, 1) = boxColour(1);
        img(y2-2:y2,   x1:x2, 2) = boxColour(2);
        img(y2-2:y2,   x1:x2, 3) = boxColour(3);
        img(y1:y2, x1:x1+2, 1)   = boxColour(1);
        img(y1:y2, x1:x1+2, 2)   = boxColour(2);
        img(y1:y2, x1:x1+2, 3)   = boxColour(3);
        img(y1:y2, x2-2:x2, 1)   = boxColour(1);
        img(y1:y2, x2-2:x2, 2)   = boxColour(2);
        img(y1:y2, x2-2:x2, 3)   = boxColour(3);
    end

    imshow(img, 'Parent', axCAM);
    title(axCAM, sprintf('Camera  |  Detections: %d  |  Label: %s  |  Score: %.2f', ...
                          numel(detections), threatLabel, threatScore), 'Color','w');

    %% ----- Panel 3 : Security Status --------------------------------
    cla(axSTATUS);
    axis(axSTATUS, 'off');

    % Choose state colour
    stateColours = containers.Map( ...
        {'IDLE','MONITORING','THREAT_DETECTED','ALARM'}, ...
        {[0.2 0.8 0.2], [1.0 0.8 0.0], [1.0 0.4 0.0], [1.0 0.1 0.1]});
    stateStr   = char(securityState);
    stateColor = stateColours(stateStr);

    % Draw coloured background rectangle to indicate state
    rectangle('Position',[0.05 0.5 0.9 0.45], 'FaceColor', stateColor, ...
              'EdgeColor','none', 'Parent', axSTATUS);

    text(0.5, 0.72, ['STATE: ' stateStr], ...
         'HorizontalAlignment','center','FontSize',14,'FontWeight','bold', ...
         'Color','k','Parent',axSTATUS,'Units','normalized');

    % Alarm indicator
    if alarmTriggered
        alarmStr = '🚨 ALARM: DOORS LOCKED | HORN ACTIVE';
        alarmClr = 'r';
    else
        alarmStr = '🔒 System Armed - No Alarm';
        alarmClr = 'g';
    end
    text(0.5, 0.35, alarmStr, ...
         'HorizontalAlignment','center','FontSize',11,'Color',alarmClr, ...
         'Parent',axSTATUS,'Units','normalized');

    % License plate status
    if plateResult.detected
        if plateResult.authorized
            plStr = sprintf('✅ PLATE: %s  |  %s  [AUTHORIZED]', ...
                            plateResult.plateText, plateResult.ownerName);
            plClr = [0.2 0.9 0.2];
        else
            plStr = sprintf('❌ PLATE: %s  [UNAUTHORIZED]', plateResult.plateText);
            plClr = [1.0 0.3 0.3];
        end
    else
        plStr = '— No Plate Detected —';
        plClr = [0.7 0.7 0.7];
    end
    text(0.5, 0.12, plStr, ...
         'HorizontalAlignment','center','FontSize',10,'Color',plClr, ...
         'Parent',axSTATUS,'Units','normalized');

    set(axSTATUS,'XLim',[0 1],'YLim',[0 1]);
end
