clc; clear; close all;

figDir = fullfile(pwd,'figDir');
if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

oneFig = 1;
matFile0 = 'simAll1_plotStruct_resampledOriginal.mat'; %'simAll0_plotStruct.mat'
matFile1 = 'simAll1_plotStruct_resampledOriginal_Kpsi148.mat'; %'simAll1_plotStruct_resampledOriginal.mat'; %, 
%'simAll1_plotStruct_resampledOriginal_Kpsi274'; %; 

matFile0 = 'simAll0_plotStruct_resampledOriginal.mat'; %'simAll0_plotStruct.mat'
matFile1 = 'simAll2_plotStruct_resampledOriginal.mat'; %'simAll1_plotStruct_resampledOriginal.mat'; %, 

load(matFile0,'plotStruct');
plotStruct1 = plotStruct;

simPwr = plotStruct{1}.Outputs_val(1,1:end-1) + plotStruct{2}.Outputs_val(2,1:end-1);
dT =2;
t = 1:dT: length(simPwr)*dT;

figure(42)

if oneFig == 1
    pos0 = get(0,'defaultFigurePosition');
    set(gcf,'Position',[pos0(1),pos0(2),2*pos0(3),pos0(4)]);
end

if oneFig ==1
    subplot(1,2,1);
end
plot(t,simPwr,'color',0.5 *ones(1,3),'LineWidth',1.5) ; hold on;

leg{1} = 'Simulated power SOFWA verification data';

cl1 = {[0,0,1]; [0,0.8,0];[0,0.4,0]};
ls = {'-','--','-.',':'};
lw = 0.75;

vec = [1,2,4];

for sidx = 1:3 % length(plotStruct)
    idx = vec(sidx);
    simPwr = plotStruct{idx}.ysim_val(1:end-1,1) + plotStruct{idx}.ysim_val(1:end-1,2);
    plot(t,simPwr,'color', cl1{sidx},'linestyle',ls{sidx},'LineWidth',lw); % idx/2*[0,0,1]) ; hold on;
    leg{sidx + 1} = strrep(strrep(plotStruct{idx}.legStr2,':',': '), 'VAF P(T2)', 'VAF(P_2)');
    %leg{sidx + 1} = strrep(strrep(plotStruct{idx}.legStrAll,':',': '),'meas','');

end

%load('simAll1_plotStruct.mat','plotStruct');
load(matFile1,'plotStruct');
nleg = length(leg);

cl1 = {[1,0,0]; 0*[1,1,1]; [1,0,1]};

vec = [1,2,length(plotStruct)];
for sidx = 1: 3 % length(plotStruct)
    idx = vec(sidx);
    simPwr = plotStruct{idx}.ysim_val(1:end-1,1) + plotStruct{idx}.ysim_val(1:end-1,2);
    plot(t,simPwr,'color', cl1{sidx},'linestyle',ls{sidx},LineWidth=lw); % idx/2*[0,0,1]) ; hold on;
    %leg{sidx + nleg} = strrep(strrep(strrep(plotStruct{idx}.legStr2,':',': '),'meas.',''),'wind ','wind');
    leg{sidx + nleg} = strrep(strrep(strrep(strrep(plotStruct{idx}.legStr2,':',': '),'meas.',''),'wind ','wind'),...
        'VAF P(T2)', 'VAF(P_2)');

end

fs = 12;
legend(leg,'Location','northoutside','Fontsize',fs-1);
axis tight; grid on;

ylabel('\delta Power T1 + T2 (MW)','Fontsize',fs)
xlabel('Time (s)','Fontsize',fs)

if oneFig == 0
    strFig = 'PowerEstSofwa';
    print(fullfile(figDir,[strFig, matFile1(1:7)]), '-dpng');
    print(fullfile(figDir,[strFig, matFile1(1:7)]), '-depsc');
end

%legend(leg)
load('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');
itsf=921; %instant to start from, as certain sample time.
beg=(10001-itsf)/10; %instant to begin defined according to length of data
rho = 1.225; %air density in [kg m^-3]

[Inputs, Outputs, Deterministic,scalingfactors,meanvalues] = preprocessdmdid(beg, rotSpeed,time1,rotorAzimuth,nacelleYaw, pitchmode,pitch,powerGenerator,rho); %preprocess information (resample, and maintain only relevant data)
[Inputs_val, Outputs_val, Deterministic_val] = preprocessdmdval(beg, rotSpeed_val,time1_val,rotorAzimuth_val,nacelleYaw_val,pitchmode,pitch_val,scalingfactors,powerGenerator_val,rho,meanvalues); %preprocess information (resample and only relevant data)

if oneFig == 1
    subplot(5,2,2);
else
    figure(100);
    subplot(5,1,1)
end

plot(t,Inputs_val(1:end-1),'LineWidth',1.5)
axis tight; grid on;
ylabel('Yaw T1 (%)','Fontsize',fs)

if oneFig == 0
    subplot(5,1,[2:3])
else
    subplot(5,2,[4,6])
end
visualizeVAF2(1,plotStruct1,matFile1)


if oneFig == 0
    subplot(5,1,[4:5])
else
    subplot(5,2,[8,10])
end

visualizeVAF2(2,plotStruct1,matFile1)
xlabel('Time (s)','Fontsize',fs)


if oneFig == 1
strFig = 'PowerEstSofwaInOutAll';
else
strFig = 'PowerEstSofwaInOut';

end

print(fullfile(figDir,[strFig, matFile1(1:7)]), '-dpng');
print(fullfile(figDir,[strFig, matFile1(1:7)]), '-depsc');