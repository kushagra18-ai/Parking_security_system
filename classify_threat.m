function [threatScore, threatLabel] = classify_threat(detections, numDet, simTime)
%CLASSIFY_THREAT  Simulates a deep-learning threat classifier.
%
%  In production this would call:
%    detector = yolov4ObjectDetector('csp-darknet53-coco');
%    [bboxes, scores, labels] = detect(detector, frame);
%
%  Here we compute a threat score analytically from synthetic detections,
%  using a sigmoid activation to map raw evidence to [0,1].
%
%  Threat heuristics:
%    - A pedestrian close to the ego vehicle increases threat.
%    - Multiple pedestrians increase threat further.
%    - Time of night (simTime > 20 s) increases threat baseline.
%
%  Inputs:
%    detections - struct array from generate_synthetic_detections
%    numDet     - number of valid detections
%    simTime    - current simulation time (s)
%
%  Outputs:
%    threatScore - scalar in [0,1]  (higher = more dangerous)
%    threatLabel - 'SAFE' | 'SUSPICIOUS' | 'INTRUDER'

    %% Base threat from environment
    if simTime > 20                        % simulating night / low visibility
        baseThreat = 0.25;
    else
        baseThreat = 0.05;
    end

    %% Accumulate evidence from detections
    pedestrianEvidence = 0;
    vehicleEvidence    = 0;

    for i = 1:numDet
        d = detections(i);
        weight = d.Score;                  % higher confidence → more weight

        if strcmp(d.ClassLabel, 'Pedestrian')
            % Proximity factor: threat rises as distance shrinks
            proximityFactor = max(0, 1 - d.Distance / 30);
            pedestrianEvidence = pedestrianEvidence + weight * proximityFactor;
        else
            vehicleEvidence = vehicleEvidence + weight * 0.2;
        end
    end

    %% Raw threat score (logistic / sigmoid activation)
    rawThreat  = baseThreat + pedestrianEvidence + vehicleEvidence;

    % Add slight temporal noise (models sensor uncertainty)
    rawThreat  = rawThreat + 0.04 * randn();

    % Pass through sigmoid to bound in (0,1)
    threatScore = 1 / (1 + exp(-6 * (rawThreat - 0.5)));
    threatScore = max(0, min(1, threatScore));

    %% Label assignment (mirrors a Stateflow guard condition)
    if threatScore >= 0.70
        threatLabel = 'INTRUDER';
    elseif threatScore >= 0.40
        threatLabel = 'SUSPICIOUS';
    else
        threatLabel = 'SAFE';
    end
end
