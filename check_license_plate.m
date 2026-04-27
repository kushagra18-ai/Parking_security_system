function plateResult = check_license_plate(simTime, plateAppearTimes, syntheticPlates, whitelist)
%CHECK_LICENSE_PLATE  Simulates OCR-based Automated License Plate Recognition (ALPR).
%
%  In production this would call:
%    ocrResult = ocr(plateImage, 'CharacterSet', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
%    detectedPlate = strtrim(ocrResult.Text);
%
%  Here, synthetic plates "appear" at predetermined times to simulate
%  a vehicle driving into camera range.
%
%  Returns a struct:
%    plateResult.detected   - true if a plate was seen this frame
%    plateResult.plateText  - OCR-extracted plate string
%    plateResult.authorized - true if plate is on whitelist
%    plateResult.ownerName  - owner name (empty if unauthorized)

    plateResult.detected   = false;
    plateResult.plateText  = '';
    plateResult.authorized = false;
    plateResult.ownerName  = '';

    %% Check if any synthetic plate is "visible" at this simTime
    % A plate is visible for a 3-second window around its appear time
    WINDOW = 3.0;   % seconds

    for i = 1:numel(plateAppearTimes)
        if abs(simTime - plateAppearTimes(i)) <= WINDOW/2

            plateResult.detected = true;

            % Simulate OCR character-recognition noise
            cleanPlate = syntheticPlates{i};
            plateResult.plateText = add_ocr_noise(cleanPlate);

            % Whitelist lookup
            [found, idx] = ismember(cleanPlate, whitelist.plates);
            plateResult.authorized = found;
            if found
                plateResult.ownerName = whitelist.owners{idx};
            end
            return;  % one plate per frame is sufficient
        end
    end
end


%% ====================================================================
%  LOCAL HELPER: Add realistic OCR noise to a plate string
%% ====================================================================
function noisyPlate = add_ocr_noise(plate)
%ADD_OCR_NOISE  Randomly swaps similar-looking characters (O↔0, I↔1, etc.)
%  with a small probability to simulate real OCR imperfections.

    ocrConfidence = 0.92;    % 92% per-character accuracy

    noisyPlate = plate;
    confusables = {'O','0'; 'I','1'; 'B','8'; 'S','5'; 'Z','2'};

    for c = 1:numel(noisyPlate)
        if rand() > ocrConfidence
            ch = noisyPlate(c);
            for r = 1:size(confusables,1)
                if ch == confusables{r,1}
                    noisyPlate(c) = confusables{r,2};
                    break;
                elseif ch == confusables{r,2}
                    noisyPlate(c) = confusables{r,1};
                    break;
                end
            end
        end
    end
end
