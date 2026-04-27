function [scenario, egoVehicle] = build_scenario()
%BUILD_SCENARIO  Creates a 3-D parking-lot scenario using drivingScenario.
%
%  FIX: smoothTrajectory requires at least 2 DISTINCT waypoints.
%       The ego vehicle is stationary/parked, so we do NOT call
%       smoothTrajectory on it at all — MATLAB keeps a static actor
%       in place automatically when no trajectory is assigned.
%
%  Returns:
%    scenario   - drivingScenario object
%    egoVehicle - actor handle for the owner's car

    %% Create the driving scenario
    scenario = drivingScenario('StopTime',  30, ...
                               'SampleTime', 0.1);

    %% ---- Road / Parking Lot Surface --------------------------------
    roadCenters = [0  0  0;
                   40 0  0];
    laneSpec = lanespec(4, 'Width', 3.5);
    road(scenario, roadCenters, 'Lanes', laneSpec, 'Name', 'ParkingLot');

    %% ---- Static Parked Cars ----------------------------------------
    vehicle(scenario, ...
        'ClassID',  1, ...
        'Position', [10, 5, 0], ...
        'Name',     'ParkedCar_1');

    vehicle(scenario, ...
        'ClassID',  1, ...
        'Position', [20, -5, 0], ...
        'Name',     'ParkedCar_2');

    %% ---- Dynamic Pedestrian Actors ---------------------------------

    % Intruder: approaches ego  (30m -> 15m -> 5m)
    % 3 distinct waypoints avoids the "at least two waypoints" error
    ped1 = actor(scenario, ...
        'ClassID', 4, 'Length', 0.5, 'Width', 0.5, 'Height', 1.7, ...
        'Name',    'Pedestrian_Intruder');

    waypoints1 = [30,  3, 0;
                  15,  3, 0;
                   5,  3, 0];
    speed1 = [1.2; 1.2; 1.2];
    smoothTrajectory(ped1, waypoints1, speed1);

    % Owner: walks away from ego  (2m -> 8m -> 15m)
    ped2 = actor(scenario, ...
        'ClassID', 4, 'Length', 0.5, 'Width', 0.5, 'Height', 1.7, ...
        'Name',    'Pedestrian_Owner');

    waypoints2 = [ 2, -3, 0;
                   8, -3, 0;
                  15, -3, 0];
    speed2 = [1.0; 1.0; 1.0];
    smoothTrajectory(ped2, waypoints2, speed2);

    %% ---- Ego Vehicle (stationary — NO smoothTrajectory call) -------
    %  Calling smoothTrajectory([p; p], [0;0]) with identical rows
    %  throws "You must specify at least two waypoints."
    %  Solution: simply set Position and leave trajectory unassigned.
    egoVehicle = vehicle(scenario, ...
        'ClassID',  1, ...
        'Position', [2, 0, 0], ...
        'Name',     'EgoVehicle_Owner');

    %% ---- Visualise the Scenario ------------------------------------
    figure('Name', 'Virtual Parking Lot - Bird''s Eye View', ...
           'NumberTitle', 'off', 'Position', [50 50 700 500]);
    plot(scenario, 'Waypoints', 'on', 'RoadCenters', 'on');
    title('Virtual Parking Lot Scenario');
    xlabel('X (m)'); ylabel('Y (m)');

    fprintf('   -> Scenario built: 2 parked cars, 2 pedestrians, 1 ego vehicle.\n');
end
