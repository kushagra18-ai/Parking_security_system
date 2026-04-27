%% =========================================================
%  AI-DRIVEN VEHICLE SECURITY SYSTEM
%  Main Script - Run this file to start the simulation
%  =========================================================
%  Authors : Jessica Goel, Aditi Gupta, Kushagra Rastogi
%  Course  : Applied Mathematical Computation (24B35EC212)
%  Submitted to: Prof. Juhi Gupta
% ==========================================================

clc; clear; close all;

fprintf('==============================================\n');
fprintf('   AI-DRIVEN VEHICLE SECURITY SYSTEM\n');
fprintf('   JIIT - Applied Mathematical Computation\n');
fprintf('==============================================\n\n');

%% STEP 1: Build the virtual driving scenario
fprintf('[1/5] Building virtual environment...\n');
[scenario, egoVehicle] = build_scenario();

%% STEP 2: Setup synthetic camera (vision detection generator)
fprintf('[2/5] Setting up synthetic camera sensor...\n');
camera = setup_camera(egoVehicle);

%% STEP 3: Load whitelist of authorized license plates
fprintf('[3/5] Loading license plate whitelist database...\n');
whitelist = load_whitelist();

%% STEP 4: Run Security Simulation
fprintf('[4/5] Running security simulation...\n');
run_security_simulation(scenario, camera, whitelist);

%% STEP 5: Display Summary Report
fprintf('[5/5] Simulation complete. Displaying report...\n');
display_report();
