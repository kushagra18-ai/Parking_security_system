%% =========================================================
%  MATHEMATICAL ANALYSIS
%  AI-Driven Vehicle Security System
%  Applied Mathematical Computation - 24B35EC212
% ==========================================================
%  Run this script independently to see the mathematical
%  foundations used in the project.
% ==========================================================

clc; clear; close all;

fprintf('=== Mathematical Analysis: AI Vehicle Security System ===\n\n');

%% ================================================================
%  1. SIGMOID ACTIVATION FUNCTION (Threat Classifier Core)
%% ================================================================
fprintf('1. Sigmoid Activation Function (Threat Classifier)\n');

x = linspace(-3, 3, 500);
sigma = @(x) 1 ./ (1 + exp(-x));       % Standard sigmoid
scaledSigma = @(x, k, x0) 1 ./ (1 + exp(-k*(x - x0)));  % Shifted sigmoid

figure('Name','Mathematical Analysis','NumberTitle','off', ...
       'Position',[100 100 1200 800], 'Color',[0.1 0.1 0.1]);

subplot(2,3,1);
y_std   = sigma(x);
y_k6    = scaledSigma(x, 6, 0.5);       % used in classify_threat.m
plot(x, y_std, 'c-', 'LineWidth', 1.5); hold on;
plot(x, y_k6,  'y--','LineWidth', 1.5);
yline(0.70,'r:','Alarm (0.70)','LineWidth',1);
yline(0.40,'m:','Alert (0.40)','LineWidth',1);
xlabel('Raw Evidence Score'); ylabel('Threat Score');
title('Sigmoid Activation','Color','w');
legend({'σ(x)','σ_{k=6}(x-0.5)','Alarm Threshold','Alert Threshold'}, ...
       'TextColor','w','Color',[0.2 0.2 0.2]);
grid on; set(gca,'Color',[0.15 0.15 0.15],'XColor','w','YColor','w');
hold off;

%% ================================================================
%  2. DETECTION PROBABILITY MODEL (P_d vs SNR)
%% ================================================================
fprintf('2. Detection Probability vs. Range\n');

range_m     = 0:0.5:50;                 % distance from camera (m)
P_detection = max(0, 1 - range_m/50);  % linear falloff used in synthetic sensor
P_det_exp   = exp(-range_m / 20);      % exponential decay alternative

subplot(2,3,2);
plot(range_m, P_detection, 'g-',  'LineWidth',1.5); hold on;
plot(range_m, P_det_exp,   'y--', 'LineWidth',1.5);
xline(30,'r:','Alert Zone 30m','LineWidth',1);
xlabel('Range (m)'); ylabel('P(detection)');
title('Detection Probability vs Range','Color','w');
legend({'Linear Model','Exponential Model','Alert Zone'}, ...
       'TextColor','w','Color',[0.2 0.2 0.2]);
grid on; set(gca,'Color',[0.15 0.15 0.15],'XColor','w','YColor','w');
hold off;

%% ================================================================
%  3. BAYESIAN THREAT UPDATE
%     P(threat | detection) = P(det|threat)*P(threat) / P(det)
%% ================================================================
fprintf('3. Bayesian Posterior Threat Probability\n');

% Prior: P(threat)
P_threat_prior = linspace(0.01, 0.99, 200);

% Likelihood parameters (typical values for a parking lot)
P_det_given_threat    = 0.95;   % true positive rate
P_det_given_no_threat = 0.05;   % false positive rate

% Total probability of detection
P_det = P_det_given_threat .* P_threat_prior + ...
        P_det_given_no_threat .* (1 - P_threat_prior);

% Bayesian posterior
P_threat_posterior = (P_det_given_threat .* P_threat_prior) ./ P_det;

subplot(2,3,3);
plot(P_threat_prior, P_threat_posterior, 'm-', 'LineWidth', 2);
hold on;
plot([0 1], [0 1], 'w:', 'LineWidth', 1);   % prior = posterior line
xlabel('P(threat) prior'); ylabel('P(threat|detection) posterior');
title('Bayesian Threat Update','Color','w');
legend({'Posterior','Prior = Posterior'}, ...
       'TextColor','w','Color',[0.2 0.2 0.2]);
grid on; set(gca,'Color',[0.15 0.15 0.15],'XColor','w','YColor','w');
hold off;

%% ================================================================
%  4. OCR ACCURACY MODEL (Binomial Distribution)
%     Given n characters and per-character accuracy p,
%     what is P(all n correct)?
%% ================================================================
fprintf('4. OCR Full-Plate Accuracy (Binomial Model)\n');

p_char = 0.92;                          % per-character OCR accuracy
n_char = 1:15;                          % plate lengths 1..15 chars
P_fullPlate = p_char .^ n_char;         % P(all n correct) = p^n

subplot(2,3,4);
bar(n_char, P_fullPlate * 100, 'FaceColor', [0.2 0.6 1.0]);
xlabel('Number of Characters in Plate');
ylabel('P(Full Plate Correct) %');
title('OCR Plate Accuracy vs Length','Color','w');
yline(80,'r--','80% target','LineWidth',1);
grid on; set(gca,'Color',[0.15 0.15 0.15],'XColor','w','YColor','w');
text(10, 85, sprintf('p_{char}=%.2f', p_char), ...
     'Color','w', 'FontSize', 9);

%% ================================================================
%  5. CONFUSION MATRIX (Simulated 100-trial classifier performance)
%% ================================================================
fprintf('5. Confusion Matrix (100 simulated trials)\n');

% Simulated results (based on system parameters)
%                  Predicted: Safe  Suspicious  Intruder
CM = [42,  3,  0;   % Actual: Safe
       2, 18,  3;   % Actual: Suspicious
       0,  2, 30];  % Actual: Intruder

subplot(2,3,5);
imagesc(CM);
colormap(gca, parula);
colorbar;
set(gca,'XTick',1:3,'XTickLabel',{'Safe','Suspicious','Intruder'}, ...
        'YTick',1:3,'YTickLabel',{'Safe','Suspicious','Intruder'}, ...
        'XColor','w','YColor','w','Color',[0.15 0.15 0.15]);
xlabel('Predicted Class','Color','w');
ylabel('Actual Class','Color','w');
title('Threat Classifier Confusion Matrix','Color','w');

% Annotate cells
for r = 1:3
    for c = 1:3
        text(c, r, num2str(CM(r,c)), 'HorizontalAlignment','center', ...
             'FontWeight','bold','FontSize',12,'Color','w');
    end
end

% Compute accuracy
accuracy = trace(CM) / sum(CM(:)) * 100;
fprintf('   Classifier Accuracy: %.1f%%\n', accuracy);

%% ================================================================
%  6. THREAT SCORE TIMELINE (Simulated 30-second run)
%% ================================================================
fprintf('6. Simulated Threat Score Timeline\n');

rng(42);   % fix seed for reproducibility
t     = 0 : 0.1 : 30;
score = zeros(size(t));

for i = 1:numel(t)
    ti = t(i);
    if ti < 4
        base = 0.05 + 0.02*randn();
    elseif ti < 8
        base = 0.30 + 0.08*randn();      % pedestrian approaches
    elseif ti < 16
        base = 0.65 + 0.10*randn();      % intruder close
    elseif ti < 22
        base = 0.25 + 0.05*randn();      % owner returns
    elseif ti < 28
        base = 0.72 + 0.08*randn();      % second intruder
    else
        base = 0.05 + 0.02*randn();      % alarm reset
    end
    score(i) = 1 / (1 + exp(-6*(base - 0.5)));
    score(i) = max(0, min(1, score(i)));
end

subplot(2,3,6);
plot(t, score, 'c-', 'LineWidth', 1.2); hold on;
yline(0.70,'r--','Alarm (0.70)','LineWidth',1,'Color','r');
yline(0.40,'y--','Alert (0.40)','LineWidth',1,'Color','y');
fill([t, fliplr(t)], [min(score,0.40), 0.40*ones(size(t))], ...
     'g', 'FaceAlpha',0.1,'EdgeColor','none');
fill([t, fliplr(t)], [min(score,0.70), 0.70*ones(size(t))], ...
     'y', 'FaceAlpha',0.08,'EdgeColor','none');
xlabel('Time (s)','Color','w');
ylabel('Threat Score','Color','w');
title('Simulated Threat Score Timeline','Color','w');
ylim([0 1]); grid on;
set(gca,'Color',[0.15 0.15 0.15],'XColor','w','YColor','w');
hold off;

sgtitle('AI Vehicle Security – Mathematical Foundations', ...
        'Color','w','FontSize',14,'FontWeight','bold');

fprintf('\nAll 6 analyses complete.\n');
