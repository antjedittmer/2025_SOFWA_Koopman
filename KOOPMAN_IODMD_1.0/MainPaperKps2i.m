%% Data handling
clc; close all; clear;

restoredefaultpath;
addpath('./1.ASSESS_DATA','./2.DYNAMIC_MODE_DECOMPOSITION','./3.VALIDATION'); %'./4.DYNAMICAL_ANALYSIS','./5.REBUILD','./6.MODEL_PC','OTHER');
addpath(genpath(fullfile(fileparts(pwd),'data')))
p = genpath('Functions'); addpath(p)

maindir = [pwd,'/matlab_code_tests/']; %directory to save results
codedir = mfilename('fullpath');
parentdir = fileparts(fileparts(codedir));
DataIn = fullfile(parentdir,'data');

pitchmode = 0; %0 for wake redirection control (yaw) and 1 for axial induction control (pitch)
dirName={[ DataIn,'/yaw_control/steps_yaw_20deg_10offset']}; %directory for identification data, wake redirection control
dirName_val={[ DataIn,'/yaw_control/steps_yaw_20deg_10offset_val']}; %directory for validation data, wake redirection control
analysis ='YAW_MPC_offset_test'; %name of directory to be created to automatically store results
filename ='yaw_control/U_data_complete_vec_yaw_off.mat'; %directory for matlab file with flow field identification data set
filenamevalid ='yaw_control/U_data_complete_vec_yaw_off_val.mat'; %directory for matlab file with flow field validation data set

datOutputDir = 'datOutputDir'; % create output directory
if exist(datOutputDir,'dir') ~= 7
    mkdir(datOutputDir);
end

detrendingstates = 1; %1 to take mean flow and consider turbulent fluctuations
method = 3; %0: DMD ; 1:DMDc; 2:IODMD; 3:EIODMD
videos = 0; %generate videos
snapshots = 0; %generate snapshots from simulation data
koopmanVec = 3; %to add deterministic states to flow field data
retakePoint = 1;
r = 100;

% Turbine and flow characteristics to be used
rho = 1.225; %air density in [kg m^-3]
D = 178; %Rotor Diameter used in simulations: 178 [m]
dt = 2; %time sampling
maindir = strcat(maindir,analysis);  %define main directory

%% Load the data
load(filename);
valid = load(filenamevalid);

itsf = 921; %instant to start from, as certain sample time.
beg = (10001-itsf)/10; %instant to begin defined according to length of data
%begin=750;
%beg=750;

% Read identification and validation data
if exist('DataSetTurbineUsed.mat','file') == 2
    load('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');
else
    [rotSpeed, nacelleYaw, time1,rotorAzimuth,pitch,powerGenerator] = readdmdinformation(dirName); %read information from simulation
    [rotSpeed_val, nacelleYaw_val,time1_val,rotorAzimuth_val,pitch_val,powerGenerator_val] = readdmdinformation(dirName_val); %read information from simulation
    save('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');
end

%% Retake points

if retakePoint == 0

    %for not using all grid points and only part of them (example,
    %only between first and second turbine)
    [~,~,~,~,~,~,QQ_u1] = retakepoints(QQ_u,x,y,z,Decimate);
    [xxx,yyy,zzz,XX,YY,ZZ,valid.QQ_u1] = retakepoints(valid.QQ_u,x,y,z,Decimate);

    [~,~,~,~,~,~,QQ_v1] = retakepoints(QQ_v,x,y,z,Decimate);
    [~,~,~,~,~,~,QQ_w1] = retakepoints(QQ_w,x,y,z,Decimate);

    [~,~,~,~,~,~,valid.QQ_v1] = retakepoints(valid.QQ_v,x,y,z,Decimate);
    [~,~,~,~,~,~,valid.QQ_w1] = retakepoints(valid.QQ_w,x,y,z,Decimate);

elseif retakePoint == 1

    %for not using all grid points and only part of them (example,
    %only between first and second turbine)
    [~,~,~,~,~,~,QQ_u1] = retakepoints_at_turbine(QQ_u,x,y,z,Decimate);
    [xxx,yyy,zzz,XX,YY,ZZ,valid.QQ_u1] = retakepoints_at_turbine(valid.QQ_u,x,y,z,Decimate);

    [~,~,~,~,~,~,QQ_v1] = retakepoints_at_turbine(QQ_v,x,y,z,Decimate);
    [~,~,~,~,~,~,QQ_w1] = retakepoints_at_turbine(QQ_w,x,y,z,Decimate);

    [~,~,~,~,~,~,valid.QQ_v1] = retakepoints_at_turbine(valid.QQ_v,x,y,z,Decimate);
    [~,~,~,~,~,~,valid.QQ_w1] = retakepoints_at_turbine(valid.QQ_w,x,y,z,Decimate);
else
    %for not using all grid points and only part of them (example,
    %only between first and second turbine)
    [~,~,~,~,~,~,QQ_u1] = retakepoints_at_turbinedisk(QQ_u,x,y,z,Decimate);
    [xxx,yyy,zzz,XX,YY,ZZ,valid.QQ_u1] = retakepoints_at_turbinedisk(valid.QQ_u,x,y,z,Decimate);

    [~,~,~,~,~,~,QQ_v1] = retakepoints_at_turbinedisk(QQ_v,x,y,z,Decimate);
    [~,~,~,~,~,~,QQ_w1] = retakepoints_at_turbine(QQ_w,x,y,z,Decimate);

    [~,~,~,~,~,~,valid.QQ_v1] = retakepoints_at_turbinedisk(valid.QQ_v,x,y,z,Decimate);
    [~,~,~,~,~,~,valid.QQ_w1] = retakepoints_at_turbinedisk(valid.QQ_w,x,y,z,Decimate);
end

%% Concatenate and detrend flow fields/states if desired

% Define states to be used for DMD
%states=QQ_u1(:,(begin-beg)+1:end); % define states: first hypothesis
states_u = QQ_u1(:,(itsf-1)*0.1:end); %fluid flow as states, identification data set
states_v = QQ_v1(:,(itsf-1)*0.1:end); states_w = QQ_w1(:,(itsf-1)*0.1:end);
states0 = [states_u; states_v; states_w];
statesvalid_u = valid.QQ_u1(:,(itsf-1)*0.1:end); %fluid flow as states, validaiton data set for comparison
statesvalid_v = valid.QQ_v1(:,(itsf-1)*0.1:end); %fluid flow as states, identification data set
statesvalid_w = valid.QQ_v1(:,(itsf-1)*0.1:end);
statesvalid0 = [statesvalid_u; statesvalid_v; statesvalid_w];

if detrendingstates == 1
    [states1all,meansteadystate,scalingfactor] = preprocessstates(states0); %remove meanflow or other pre-processing techniques to experiment
    [statesvalid1all]=preprocessstates(statesvalid0,scalingfactor);
else
    states1all = states0;
    statesvalid1all = statesvalid0;
end

% Process validation data
[Inputs, Outputs, Deterministic,scalingfactors,meanvalues] = preprocessdmdid(beg, rotSpeed,time1,rotorAzimuth,nacelleYaw, pitchmode,pitch,powerGenerator,rho); %preprocess information (resample, and maintain only relevant data)
[Inputs_val, Outputs_val, Deterministic_val] = preprocessdmdval(beg, rotSpeed_val,time1_val,rotorAzimuth_val,nacelleYaw_val,pitchmode,pitch_val,scalingfactors,powerGenerator_val,rho,meanvalues); %preprocess information (resample and only relevant data)

%% (2) DYNAMIC MODE DECOMPOSITION

if retakePoint == 0
    strRetake = 'All wind meas.';
else
    strRetake = 'Turbine wind meas.';
end

%% Start loop over
% states1 = Deterministic;
% statesvalid1 = Deterministic_val;

noStateUV = 1/3 * size(states1all,1); %u and v selected
states1 = states1all(1:noStateUV,:);
statesvalid1 = statesvalid1all(1:noStateUV,:);


PolyLiftingFunction = 0;
noStates = [4,6,12,24];

aMatFilename = sprintf('simAll%d_plotStruct_resampledOriginal_Kpsi%d.mat',retakePoint,noStates(end));
aMatFullfilename = fullfile(datOutputDir,aMatFilename);


for idx = 1: length(noStates)
    koopman = koopmanVec;
    noState = noStates(idx);
    r = 100;

    %% states from wind flow field
    statesWind = [states1; states1.^2; states1.^3]; %[states_u; states_u.^2; statesvalid_u.^3];
    statesWindvalid = [statesvalid1; statesvalid1.^2; statesvalid1.^3];
    strKoop = sprintf('Lin, q. + c., n_g = %d',noStates(idx));

    structPrev.Ur1_prev1 = Deterministic(1,1);
    structPrev.Ur2_prev1 = Deterministic(2,1);
    structPrev.dUr1_prev1 = 0;
    structPrev.dUr2_prev1 = 0;
    structPrev.M1(1) = Deterministic(1,1); % Moving mean
    structPrev.M2(1) = Deterministic(2,1);
    structPrev.k = 1;

    statesUr = nan(noState,size(Deterministic,2));
    for idxK = 1: length(Deterministic)
        [statesUr(:,idxK),stateNameUr,structPrev]  = K_psi_3D(Deterministic(:,idxK),noState,structPrev,PolyLiftingFunction);
    end

    % windAtTurbine = [QQ_u1; QQ_v1];
    % statesUV = koopmanstateextensionWFSim(windAtTurbine,poly,n);
    % stateNameUV = regexprep(stateNameUr,{'Ur1','Ur2','M'},{'u','v','Muv'});
    states = statesWind; %[statesUr]; %;statesUV];
    Deterministic = statesUr;
    stateName = [stateNameUr]; %,';',stateNameUV];

    structPrev.Ur1_prev1 = Deterministic_val(1,1);
    structPrev.Ur2_prev1 = Deterministic_val(2,1);
    structPrev.dUr1_prev1 = 0;
    structPrev.dUr2_prev1 = 0;
    structPrev.M1(1) = Deterministic_val(1,1); % Moving mean
    structPrev.M2(1) = Deterministic_val(2,1);
    structPrev.k = 1;
    statesvalidUr = nan(noState,size(Deterministic_val,2));
    for idxK = 1: length(Deterministic_val)
        [statesvalidUr(:,idxK),stateNameUr,structPrev]  = K_psi_3D(Deterministic_val(:,idxK),noState,structPrev,PolyLiftingFunction);
    end
    % windAtTurbineVal = [valid.QQ_u1; valid.QQ_v1];
    % statesUV_val = koopmanstateextensionWFSim(windAtTurbineVal,poly,n);
    statesvalid = statesWindvalid;  %;statesUV_val];
    Deterministic_val =statesvalidUr;


    n = size(states,1);
    r = min(r,n); %define truncation level for Singular Value Decomposition

    % states=double(states); %ensure states are double and not single matrix
    % statesvalid=double(statesvalid); %ensure correpsonding vliadation states are double and not single matrix
    f = '';
    plotView = 0; plotOn = 0;
    [sys_red,FITje,U,S,V,method,X,X_p,Xd,dirdmd,xstates]=dynamicmodedecomposition(states,Inputs, Outputs, Deterministic,method,r,maindir,f,dt,plotView,plotOn);
    save(strcat(dirdmd,'/OPTIONS.mat'),'detrendingstates','method','koopman','rho','D','dt','dirName','dirName_val');

    % plotView = 1; plotOn = 1;
    % si = 7;
    % purpose = ''; x = '';
    % OMEGA = ''; DAMPING = '';
    % [FITje,OMEGA,DAMPING,fig1,x]=evaluatemodel(sys_red,si,Inputs, Outputs,FITje,OMEGA,DAMPING,purpose,x,states,U,Deterministic,method,plotView,plotOn)

    %% (3) DATA VALIDATION
    % Validate Models from validation data set
    [FITje_val,dirdmd_val,xstatesvalid] = validatemodels(sys_red,Inputs_val,Outputs_val,r,strcat(dirdmd, '/val'),f,statesvalid,U,Deterministic_val,method,plotView,plotOn);
    save(strcat(dirdmd,'/FIT.mat'),'FITje_val','FITje');

    % [modelVAF_val]=idvaloverview(FITje,FITje_val,dirdmd,'VAFidandval');  %overview of models results (identification and validation)
    [a,b] = max(FITje_val(2,1:r)); %best performing model, only analysing first 50
    [a1,b1] = max(FITje_val(1,1:r));
    [aId,b1] = max(FITje(2,1:r)); %best performing model, only analysing first 50
    [a1Id,b1] = max(FITje(1,1:r));

    fprintf('Best performance T2, T1: %2.3f, %2.3f, model states %d\n', a, FITje_val(1,b),b);

    purpose = ''; x = '';
    OMEGA = ''; DAMPING = '';
    plotView = 0; plotOn =0;
    %sys_red,si,Inputs, Outputs,FITje,OMEGA,DAMPING,purpose,x,states,U,Deterministic,method
    [~,~,~,~,~,ysim_val] = evaluatemodel(sys_red,b,Inputs_val,Outputs_val,FITje_val,OMEGA,DAMPING,purpose,x,statesvalid,U,Deterministic_val,method,plotView,plotOn);
    %plot(Outputs(1,1:end-1) + Outputs(2,1:end-1)) ; hold on; plot(ysim_val(:,1) + ysim_val(:,2));
    [~,~,~,~,~,ysim] = evaluatemodel(sys_red,b,Inputs_val,Outputs,FITje,OMEGA,DAMPING,purpose,x,...
        states,U,Deterministic,method,plotView,plotOn);

    plotStruct{idx}.Outputs_val = Outputs_val;
    plotStruct{idx}.ysim_val = ysim_val;
    plotStruct{idx}.Outputs = Outputs;
    plotStruct{idx}.ysim = ysim;

    plotStruct{idx}.a = a;
    plotStruct{idx}.a1 = a1;
    plotStruct{idx}.noState = size(states,1);
    plotStruct{idx}.noStateVAF = b;
    plotStruct{idx}.legStrAllId =  sprintf('%s; %s; Id VAF P(T1)/P(T2):%2.2f%%/%2.2f%%', strRetake,strKoop,a1Id,aId);
    plotStruct{idx}.legStrAll =  sprintf('%s; %s; VAF P(T1)/P(T2):%2.2f%%/%2.2f%%', strRetake,strKoop,a1,a);
    plotStruct{idx}.legStr1 =  sprintf('%s; %s; VAF P(T1):%2.2f%%', strRetake,strKoop,a1);
    plotStruct{idx}.legStr2 =  sprintf('%s; %s; VAF P(T2):%2.2f%%', strRetake,strKoop,a);

end
save(aMatFullfilename,'plotStruct');

%% calculate the RMSE
simPwr1 = plotStruct{1}.Outputs_val(1,1:end-1) * scalingfactors(1) + meanvalues(1);
simPwr2 = plotStruct{1}.Outputs_val(2,1:end-1) * scalingfactors(2) + meanvalues(2);
simPwrRef = (simPwr1 + simPwr2)/10^6;

RMSEvec = nan(length(plotStruct),1);
for idx = 1:length(plotStruct)
    simPwr1 = plotStruct{idx}.ysim_val(1:end-1,1) * scalingfactors(1) + meanvalues(1);
    simPwr2 = plotStruct{idx}.ysim_val(1:end-1,2) * scalingfactors(2) + meanvalues(2);
    simPwr = (simPwr1 + simPwr2)/10^6;
    RMSEvec(idx) = sqrt(mean((simPwr -simPwrRef').^2));
end
NRMSE_pct = (RMSEvec/ mean(simPwrRef)) * 100;
RMSEveckW = RMSEvec *1000;

%%
aTextFile = strrep(strrep(strrep(aMatFullfilename,'simAll','VAF_retake'),'_plotStruct', ''),'.mat','.txt');
fid = fopen(aTextFile,'w');

fprintf(fid,'Data subset & Lifting functions & Koop omega & States \\zeta & Selected States \\tilde{\\zeta} & VAF(P_1) & VAF(P_2) & NRMSE \n');

for idx = 1 : length(plotStruct)
    % fprintf('%s\n',plotStruct{idx}.legStrAllId);
    % fprintf('%s\n',plotStruct{idx}.legStrAll);

    aStruct = plotStruct{idx};
    aStructCell = regexp(aStruct.legStrAll,';','split');
    matches = regexp(aStruct.legStrAllId, '(\d+\.\d+)(?=%)', 'match');
    vaf_values = str2double(matches);
    fprintf(fid, '%s & %s & %d %d & %d & %2.2f\\ & %2.2f\\%% & %2.2f\\%% \n', aStructCell{1}, aStructCell{2}, noStates(idx),...
        aStruct.noState, aStruct.noStateVAF, aStruct.a1, aStruct.a, NRMSE_pct(idx));

end
fclose(fid);

fprintf('Results in mat file: %s\n',aMatFullfilename)
fprintf('Printed to txt file: %s\n',aTextFile)





