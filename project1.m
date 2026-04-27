% Test scenario builder
[scenario, ego] = build_scenario();

% Test whitelist
wl = load_whitelist();
disp(wl.plates)

% Test threat classifier with dummy data
det.ClassLabel = 'Pedestrian'; det.Score = 0.9; det.Distance = 8;
[score, label] = classify_threat(det, 1, 14.0)

% Test OCR plate checker
result = check_license_plate(12.0, [5,12,20,26], ...
  {'UP16AB1234','UNKNOWN_99','DL01CD5678','XYZ_THREAT'}, load_whitelist())