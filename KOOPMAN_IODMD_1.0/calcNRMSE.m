clc; clear; close all;

figDir = fullfile(pwd,'figDir');
if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

load('DataSetScaling.mat', 'scalingfactors','meanvalues');

oneFig = 0;
matFile0 = 'simAll1_plotStruct_resampledOriginal.mat'; %'simAll0_plotStruct.mat'
matFile1 = 'simAll1_plotStruct_resampledOriginal_Kpsi148.mat'; %'simAll1_plotStruct_resampledOriginal.mat'; %,
%'simAll1_plotStruct_resampledOriginal_Kpsi274'; %;

% matFile0 = 'simAll0_plotStruct_resampledOriginal.mat'; %'simAll0_plotStruct.mat'
% matFile1 = 'simAll2_plotStruct_resampledOriginal.mat'; %'simAll1_plotStruct_resampledOriginal.mat'; %,

load(matFile0,'plotStruct');
plotStruct1 = plotStruct;


%% Calculate true power
simPwr1 = plotStruct{1}.Outputs_val(1,1:end-1) * scalingfactors(1) + meanvalues(1);
simPwr2 = plotStruct{2}.Outputs_val(2,1:end-1) * scalingfactors(2) + meanvalues(2);
simPwrRef = (simPwr1 + simPwr2)/10^6;

dT = 2;
t = 1:dT: length(simPwrRef)*dT;

vec = 1:4;
RMSEvec = nan(8,1);
for idx = 1:4 % length(plotStruct)
    simPwr1 = plotStruct{idx}.ysim_val(1:end-1,1) * scalingfactors(1) + meanvalues(1);
    simPwr2 = plotStruct{idx}.ysim_val(1:end-1,2) * scalingfactors(2) + meanvalues(2);
    simPwr = (simPwr1 + simPwr2)/10^6;
    RMSEvec(idx) = sqrt(mean((simPwr -simPwrRef').^2));
      
end

load(matFile1,'plotStruct');
vec = [1:3,length(plotStruct)];
for sidx = 1: length(vec)
    idx = vec(sidx);
    simPwr1 = plotStruct{idx}.ysim_val(1:end-1,1) * scalingfactors(1) + meanvalues(1);
    simPwr2 = plotStruct{idx}.ysim_val(1:end-1,2) * scalingfactors(2) + meanvalues(2);
    simPwr = (simPwr1 + simPwr2)/10^6;
    RMSEvec(sidx+4) = sqrt(mean((simPwr -simPwrRef').^2));
end


NRMSE_pct = (RMSEvec/ mean(simPwrRef)) * 100;
RMSEveckW = RMSEvec *1000;

 %6.9327    6.5263    6.8058    4.9628    5.2161    4.9125
save(['RMSE', matFile1(1:7),'.mat'], "NRMSE_pct","RMSEveckW");