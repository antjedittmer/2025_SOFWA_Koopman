clc; clear; close all;

addpath('2.DYNAMIC_MODE_DECOMPOSITION');

figDir = fullfile(pwd,'figDir');
if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

load('DataSetScaling.mat', 'scalingfactors','meanvalues');

setTurbine = 0;

datDir = 'datOutputDir';

if setTurbine == 1
    matFile0 = fullfile(datDir,'simAll1_plotStruct_long70.mat'); %'simAll1_plotStruct_resampledOriginal.mat';
    matFile1 = fullfile(datDir,'simAll1_plotStruct_resampledOriginal_Kpsi24.mat'); %';
else
    matFile0 = fullfile(datDir,'simAll0_plotStruct.mat'); %'simAll0_plotStruct_resampledOriginal.mat'; %'simAll0_plotStruct.mat'
    matFile1 = fullfile(datDir,'simAll2_plotStruct_long70.mat'); %'simAll2_plotStruct_resampledOriginal.mat'; %'simAll1_plotStruct_resampledOriginal.mat'; %,
end

load(matFile0,'plotStruct');
plotStruct1 = plotStruct;

%% Calculate true power
simPwr1 = plotStruct{1}.Outputs_val(1,1:end) * scalingfactors(1) + meanvalues(1);
simPwr2 = plotStruct{2}.Outputs_val(2,1:end) * scalingfactors(2) + meanvalues(2);
simPwrRef = (simPwr1 + simPwr2)/10^6;
dT = 2;
t = 1:dT: length(simPwrRef)*dT;
t0 = 0:dT: length(simPwrRef)*dT;

%% Create one figure with four subplots
figure('Name','AllResults','NumberTitle','off');
pos0 = get(0,'defaultFigurePosition');
set(gcf,"Position",[pos0(1), pos0(2)- 0.5*pos0(4), pos0(3),1*pos0(4)])

tiledlayout(7, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

fs = 12; % font size for all plots

%% --- Subplot 1: Non-scaled yaw input (converted to degrees) ---
nexttile;
load('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');
itsf=921;
beg=(10001-itsf)/10;
rho = 1.225;
[Inputs_val, Outputs_val, Deterministic_val] = preprocessdmdval(beg, rotSpeed_val,time1_val,rotorAzimuth_val,nacelleYaw_val,pitchmode,pitch_val,scalingfactors,powerGenerator_val,rho,meanvalues);

yaw_deg = Inputs_val * scalingfactors(3); % yaw in degrees
plot(t, yaw_deg, 'LineWidth', 1.5)
axis tight; grid on;
ylabel('Yaw (deg)','FontSize',fs)
xticklabels([]); % Removes X-axis labels to save space
%title('Non-scaled Yaw Input (converted)','FontSize',fs)

%% --- Subplot 2: Power comparison PT1(Simulated vs Reference) ---
nexttile([2 1]);

visualizeVAFsub(1,plotStruct,matFile1,scalingfactors,meanvalues);
xticklabels([]); % Removes X-axis labels to save space


%% --- Subplot 3: Power comparison PT1(Simulated vs Reference) ---
nexttile([2 1]);
vec2 = visualizeVAFsub(2,plotStruct,matFile1,scalingfactors,meanvalues);
xticklabels([]); % Removes X-axis labels to save space


%% --- Subplot 4: Power comparison PT1(Simulated vs Reference) ---
nexttile([2 1]);

plot(t, simPwrRef,'Color',0.5*ones(1,3),'LineWidth',1.5); hold on;

cl1 = {[0,0,1]; [0,0.6,0]; [0,0.6,0]};
ls = {'-','--','-.',':'};
vec = [1,2,4];
RMSEvec = nan(6,1);
leg{1} = 'Simulated Power';

lwVec =[1*ones(2,1); 1.5*ones(3,1)]; % line width
for sidx = vec2
    idx = vec(sidx);
    lw = lwVec(sidx);
    simPwr1 = plotStruct{idx}.ysim_val(1:end,1) * scalingfactors(1) + meanvalues(1);
    simPwr2 = plotStruct{idx}.ysim_val(1:end,2) * scalingfactors(2) + meanvalues(2);
    simPwr = (simPwr1 + simPwr2)/10^6;
    RMSEvec(sidx) = sqrt(mean((simPwr - simPwrRef').^2));
    plot(t,simPwr,'Color',cl1{sidx},'LineStyle',ls{sidx},'LineWidth',lw);
    leg{end+1} = strrep(strrep(plotStruct{idx}.legStr2,':',': '), 'VAF P(T2)', 'VAF(P_2)'); %#ok<SAGROW>
end

load(matFile1,'plotStruct');
cl2 = {[1,0,0]; [0,0,0]; [1,0,1]};
vec = [1,2,length(plotStruct)];

lwVec =[1*ones(2,1); 1.5*ones(3,1)]; % line width
for sidx = vec2
    idx = vec(sidx);
    lw = lwVec(sidx);
    simPwr1 = plotStruct{idx}.ysim_val(1:end,1) * scalingfactors(1) + meanvalues(1);
    simPwr2 = plotStruct{idx}.ysim_val(1:end,2) * scalingfactors(2) + meanvalues(2);
    simPwr = (simPwr1 + simPwr2)/10^6;
    RMSEvec(sidx+3) = sqrt(mean((simPwr - simPwrRef').^2));
    plot(t, simPwr,'Color', cl2{sidx}, 'LineStyle',ls{sidx}, 'LineWidth',lw);
    leg{end+1} = strrep(strrep(strrep(strrep(strrep(plotStruct{idx}.legStr2,':',': '),'meas.',''),...
        'wind ','wind'),'VAF P(T2)', 'VAF(P_2)'),'n_{koop}','n_{g{\omega}}'); %#ok<SAGROW>
end
axis tight; grid on;

% 1) Remove the numeric value and % after 'VAF(P_2):'
leg_clean = regexprep(leg, '(VAF\(P_2\):)\s*[0-9.]+%', '$1');

% 2) (Optional) remove any double spaces created by the replacement
leg_clean = regexprep(leg_clean, '\s{2,}', ' ');

leg_clean = strrep(strrep(strrep(leg_clean,'; VAF(P_2):',''),' meas',''),'wind.','wind');
%leg_clean = strrep(leg_clean,'wind', 'meas.');
leg_clean = strrep(leg_clean, 'All wind', 'Wind field');
leg_clean = strrep(leg_clean, 'n_g', 'n_{g\omega}');
leg_clean = strrep(leg_clean, 'n_g', 'n_{g\omega}');
leg_clean = strrep(leg_clean, 'Lin, quad. + cubic', 'Lin., quad. + cubic');
leg_clean = strrep(leg_clean, 'Turbine wind; ', '');
leg_clean = strrep(leg_clean, 'Lin, q. + c., ', 'Lin., quad. + cubic + ');

legend(leg_clean,'Location','southoutside','FontSize',fs-1,'Box','off','NumColumns',2);
axis tight; grid on;
ylabel('Pwr P_{WF} (MW)','FontSize',fs)
xlabel('Time (s)','FontSize',fs)

set(findall(gcf,'-property','FontSize'),'FontSize',11.5)

set(gcf,'Units','centimeters','Position',[0 0 17 18]);
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 17 18]);


strFig = 'aPowerEstSofwaInOut';
matFile1a = strrep(matFile1,datDir,'');

print(fullfile(figDir,[strFig, matFile1a(2:8)]), '-dpng');
print(fullfile(figDir,[strFig, matFile1a(2:8)]), '-depsc');


function vec2 = visualizeVAFsub(idx0,plotStruct,matFile1,scalingfactors,meanvalues) 

figDir = fullfile(pwd,'figDir');
if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

if ~nargin
    
    idx0 = 1;
    figure(42)
    legStr = 'legStrAll';
    load('simAll0_plotStruct.mat','plotStruct');
    matFile1 = 'simAll1_plotStruct_resampledOriginal.mat'; 
else
    legStr = sprintf('legStr%d',idx0);
end


simPwr =  plotStruct{1}.Outputs_val(idx0,1:end-1)* scalingfactors(idx0) + meanvalues(idx0);
dT =2;
t = 1:dT: length(simPwr)*dT;

plot(t,simPwr/10^6,'color',0.5 *ones(1,3),'LineWidth',1.5) ; hold on;

leg{1} = 'Simulated power SOFWA verification data';


cl1 = {[0,0,1]; [0,0.6,0];[0,0.6,0]};
ls = {'-','--','-.',':'};


vec = [1,2,4];
vec2 =[1,3]; %1:3;

lwVec =[1*ones(2,1); 1.5*ones(3,1)]; % line width
for sidx = vec2 % length(plotStruct)
    idx = vec(sidx);
    lw = lwVec(sidx);
    simPwr = plotStruct{idx}.ysim_val(1:end-1,idx0)* scalingfactors(idx0) + meanvalues(idx0);
    plot(t,simPwr/10^6,'color', cl1{sidx},'linestyle',ls{sidx},'LineWidth',lw); % idx/2*[0,0,1]) ; hold on;
    leg{sidx + 1} = plotStruct{idx}.(legStr);

end

%load('simAll1_plotStruct.mat','plotStruct');
load(matFile1,'plotStruct');

nleg = length(leg);

cl1 = {[1,0,0]; 0*[1,1,1]; [1,0,1]};

vec = [1,2,length(plotStruct)];
lwVec =[1*ones(1,1); 1.5*ones(3,1)]; % line width
for sidx = vec2 % length(plotStruct)
    idx = vec(sidx);
    lw = lwVec(sidx);
    simPwr =  plotStruct{idx}.ysim_val(1:end-1,idx0) * scalingfactors(idx0) + meanvalues(idx0);
    plot(t,simPwr/10^6,'color', cl1{sidx},'linestyle',ls{sidx},'LineWidth',lw); % idx/2*[0,0,1]) ; hold on;
    leg{sidx + nleg} = plotStruct{idx}.(legStr);
end

fs = 12;

axis tight; grid on;

strLeg = sprintf('Pwr P_%d (MW)',idx0);
ylabel(strLeg,'Fontsize',fs)
end

