function [detections, numDet] = generate_synthetic_detections(poses, simTime)
%GENERATE_SYNTHETIC_DETECTIONS
%  Uses targetPoses output (no Name field) to create synthetic detections.
%  'poses' is the struct array returned by targetPoses().

    detections = struct('ObjectClassID', {}, ...
                        'BoundingBox',   {}, ...
                        'Score',         {}, ...
                        'Distance',      {}, ...
                        'ClassLabel',    {});

    numDet = 0;

    if isempty(poses)
        return;
    end

    for k = 1:numel(poses)
        p = poses(k);

        % Distance from ego (ego is origin in targetPoses frame)
        dist = sqrt(p.Position(1)^2 + p.Position(2)^2);

        % Only detect within 50 m
        if dist > 50, continue; end

        % Detection confidence
        conf = max(0.05, min(1.0, 1 - dist/50 + 0.05*randn()));

        % Simulated bounding box in 640x480 image
        cx = 320 - p.Position(2)*5 + 10*randn();
        cy = 240 + 30*randn();
        bw = max(20, 80 - dist*1.5);
        bh = bw * 1.6;

        numDet = numDet + 1;
        detections(numDet).ObjectClassID = p.ClassID;
        detections(numDet).BoundingBox   = [cx-bw/2, cy-bh/2, bw, bh];
        detections(numDet).Score         = conf;
        detections(numDet).Distance      = dist;

        if p.ClassID == 4
            detections(numDet).ClassLabel = 'Pedestrian';
        else
            detections(numDet).ClassLabel = 'Vehicle';
        end
    end
end
