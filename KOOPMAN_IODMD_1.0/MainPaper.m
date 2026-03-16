%% Data handling
clc; close all; 
clearvars -except QQ_u QQ_v QQ_w x y z valid Decimate; 

loadMat = 0; % Switch to load matfile if available

restoredefaultpath;
addpath('./1.ASSESS_DATA','./2.DYNAMIC_MODE_DECOMPOSITION','./3.VALIDATION','OTHER');
% './4.DYNAMICAL_ANALYSIS','./5.REBUILD','./6.MODEL_PC',
addpath(genpath(fullfile(fileparts(pwd),'data')))
p = genpath('Functions'); addpath(p)

maindir = [pwd,'/matlab_code_tests/']; %directory to save results
codedir = mfilename('fullpath');
parentdir = fileparts(fileparts(codedir));
DataIn = fullfile(parentdir,'data');


datOutputDir = 'datOutputDir'; % create output directory
if exist(datOutputDir,'dir') ~= 7
    mkdir(datOutputDir);
end

pitchmode = 0; %0 for wake redirection control (yaw) and 1 for axial induction control (pitch)

if pitchmode == 0
    dirName={[ DataIn,'/yaw_control/steps_yaw_20deg_10offset']}; %directory for identification data, wake redirection control
    dirName_val={[ DataIn,'/yaw_control/steps_yaw_20deg_10offset_val']}; %directory for validation data, wake redirection control
    analysis ='YAW_MPC_offset_test'; %name of directory to be created to automatically store results
    filename ='yaw_control/U_data_complete_vec_yaw_off.mat'; %directory for matlab file with flow field identification data set
    filenamevalid ='yaw_control/U_data_complete_vec_yaw_off_val.mat'; %directory for matlab file with flow field validation data set

elseif pitchmode == 1
    dirName={[DataIn,'/pitch_control/steps_theta_col_new']}; %directory for identification data, collective pitch control
    dirName_val={[DataIn,'/pitch_control/steps_theta_col_new_val']}; %directory for validation data, collective pitch control
    analysis ='PULSE_MPC/'; % name of directory to be created to automatically store results
    filename ='pitch_control/U_data_complete_vec_pulse.mat'; %directory for matlab file with flow field identification data set
    filenamevalid ='pitch_control/U_data_complete_vec_pulse_val.mat'; %directory for matlab file with flow field validation data set

end

% Parameters
detrendingstates = 1; %1 to take mean flow and consider turbulent fluctuations
method = 3; %0: DMD ; 1:DMDc; 2:IODMD; 3:EIODMD
koopmanVec = 0:3;
retakePoint = 1;

% Turbine and flow characteristics to be used
rho = 1.225; %air density in [kg m^-3]
D = 178; %Rotor Diameter used in simulations: 178 [m]
dt = 2; %time sampling
maindir = strcat(maindir,analysis);  %define main directory

itsf = 921; %instant to start from, as certain sample time.
beg = (10001-itsf)/10; %instant to begin defined according to length of data

if retakePoint == 1 ||  retakePoint == 4
    Xsel = [1,70];
    strRetake = 'Turbine wind meas.';
elseif retakePoint == 2
    Xsel = [1,10,51,70];
    strRetake = 'Sparse wind meas.';
elseif retakePoint == 0
    Xsel = []; % Default/Empty
    strRetake = 'All wind meas.';
else
    error('strRetake not defined')
end

% Create
aMatFilename = sprintf('simAll%d_plotStruct.mat',retakePoint);
if retakePoint > 0
    endmat = ['_long',num2str(Xsel(end)),'.mat'];
    aMatFilename  = strrep(aMatFilename,'.mat', endmat);
end
aMatFullfilename = fullfile(datOutputDir,aMatFilename);

%% Load the data

if exist(aMatFullfilename,'file') == 2 && loadMat == 1
    load(aMatFullfilename,'plotStruct');
else

    % Load wind data (needs 5.507 s, only once)
    if exist('QQ_u','var') ~= 1 || length(QQ_u) ~= 96600
        load(filename, 'QQ_u', 'QQ_v', 'QQ_w', 'x','y', 'z', 'Decimate');
        valid = load(filenamevalid);
    end

    % Read or load identification and validation turbine data (needs 0.008 s)
    if exist('DataSetTurbineUsed.mat','file') == 2
        load('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');
    else
        [rotSpeed, nacelleYaw, time1,rotorAzimuth,pitch,powerGenerator] = readdmdinformation(dirName); %read information from simulation
        [rotSpeed_val, nacelleYaw_val,time1_val,rotorAzimuth_val,pitch_val,powerGenerator_val] = readdmdinformation(dirName_val); %read information from simulation
        save('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');
    end

    %% Retake points
    % Use not all grid points, but only a selection
    if isempty(Xsel)
        [~,~,~,~,~,~,QQ_u1] = retakepoints(QQ_u,x,y,z,Decimate);
        [xxx,yyy,zzz,XX,YY,ZZ,valid.QQ_u1] = retakepoints(valid.QQ_u,x,y,z,Decimate);

        [~,~,~,~,~,~,QQ_v1] = retakepoints(QQ_v,x,y,z,Decimate);
        [~,~,~,~,~,~,QQ_w1] = retakepoints(QQ_w,x,y,z,Decimate);

        [~,~,~,~,~,~,valid.QQ_v1] = retakepoints(valid.QQ_v,x,y,z,Decimate);
        [~,~,~,~,~,~,valid.QQ_w1] = retakepoints(valid.QQ_w,x,y,z,Decimate);

    else
        [~,~,~,~,~,~,QQ_u1] = retakepoints_at_turbine(QQ_u,x,y,z,Decimate,Xsel);
        [xxx,yyy,zzz,XX,YY,ZZ,valid.QQ_u1] = retakepoints_at_turbine(valid.QQ_u,x,y,z,Decimate,Xsel);

        [~,~,~,~,~,~,QQ_v1] = retakepoints_at_turbine(QQ_v,x,y,z,Decimate,Xsel);
        [~,~,~,~,~,~,QQ_w1] = retakepoints_at_turbine(QQ_w,x,y,z,Decimate,Xsel);

        [~,~,~,~,~,~,valid.QQ_v1] = retakepoints_at_turbine(valid.QQ_v,x,y,z,Decimate,Xsel);
        [~,~,~,~,~,~,valid.QQ_w1] = retakepoints_at_turbine(valid.QQ_w,x,y,z,Decimate,Xsel);

    end

    %% Concatenate and detrend flow fields/states if desired

    % Define states to be used for DMD
    states_u = QQ_u1(:,(itsf-1)*0.1:end); %fluid flow as states, identification data set
    states_v = QQ_v1(:,(itsf-1)*0.1:end);
    states_w = QQ_w1(:,(itsf-1)*0.1:end);
    states0 = [states_u; states_v; states_w];
    statesvalid_u = valid.QQ_u1(:,(itsf-1)*0.1:end); %fluid flow as states, validation data set for comparison
    statesvalid_v = valid.QQ_v1(:,(itsf-1)*0.1:end); %fluid flow as states, identification data set
    statesvalid_w = valid.QQ_w1(:,(itsf-1)*0.1:end);
    statesvalid0 = [statesvalid_u; statesvalid_v; statesvalid_w];

    if detrendingstates == 1
        [states1all,meansteadystate,scalingfactor] = preprocessstates(states0); % Devide by standard variation
        [statesvalid1all]=preprocessstates(statesvalid0,scalingfactor);
    else
        states1all = states0;
        statesvalid1 = statesvalid0;
    end

    %% Preprocess wind and turbine data
    [Inputs, Outputs, Deterministic,scalingfactors,meanvalues] = preprocessdmdid(beg, rotSpeed,time1,rotorAzimuth,nacelleYaw, pitchmode,pitch,powerGenerator,rho); %preprocess information (resample, and maintain only relevant data)
    [Inputs_val, Outputs_val, Deterministic_val] = preprocessdmdval(beg, rotSpeed_val,time1_val,rotorAzimuth_val,nacelleYaw_val,pitchmode,pitch_val,scalingfactors,powerGenerator_val,rho,meanvalues); %preprocess information (resample and only relevant data)

    %% (2) DYNAMIC MODE DECOMPOSITION

    noStateUV = 1/3 * size(states1all,1); %u and v selected
    states1 = states1all(1:noStateUV,:);
    statesvalid1 = statesvalid1all(1:noStateUV,:);

    for idx = 1: length(koopmanVec)
        koopman = koopmanVec(idx);
        r = 100;

        %include non linear observables - Koopman extensions to better recover non linear dynamics
        if koopman == 0
            states = states1;
            statesvalid = statesvalid1;
            strKoop = 'Lin.';

        elseif koopman == 1 % linear + quadratic + cubic
            states = [states1; states1.^2];
            statesvalid = [statesvalid1; statesvalid1.^2];
            strKoop = 'Lin. + quad.';

        elseif koopman == 2 % linear + cubic

            states= [states1; states1.^3];
            statesvalid = [statesvalid1; statesvalid1.^3];
            strKoop = 'Lin. + cubic';

        elseif koopman == 3 % linear + quadratic + cubic
            states= [states1; states1.^2; states1.^3]; %[states_u; states_u.^2; statesvalid_u.^3];
            statesvalid = [statesvalid1; statesvalid1.^2; statesvalid1.^3];
            strKoop = 'Lin, quad. + cubic';

        elseif koopman == 4

            multCos = cos(pi/180*Inputs);
            multCos_valid = cos(pi/180*Inputs_val);

            velSquare = (states_u(1:size(states_v,1),:).^2 + ...
                states_v(1:size(states_v,1),:).^2) .^ 0.5;

            nTurb = size(velSquare,1)/2;

            velSquareMult = [velSquare(1:nTurb,:) .* repmat(multCos,nTurb,1);
                velSquare(nTurb+1:end,:)];

            velSquare_valid = (statesvalid_u(1:size(states_v,1),:).^2 + ...
                statesvalid_v(1:size(states_v,1),:).^2) .^ 0.5;
            velSquareMult_valid = [velSquare_valid(1:nTurb,:) .* repmat(multCos_valid,nTurb,1);
                velSquare_valid(nTurb+1:end,:)];

            Ur1 = mean(velSquareMult(1:nTurb,:));
            Ur2 = mean(velSquareMult(nTurb+1:end,:));
            Ur1valid = mean(velSquareMult_valid(1:nTurb,:));
            Ur2valid = mean(velSquareMult_valid(nTurb+1:end,:));

            states= [states_u; Ur1;Ur2;Ur1.^2;Ur2.^2;Ur1.^3;Ur2.^3]; % velSquareMult.^2; velSquareMult.^3;
            statesvalid = [statesvalid_u;velSquareMult_valid.^2; velSquareMult_valid.^3; Ur2valid;Ur1valid.^2;Ur2valid.^2;Ur1valid.^3;Ur2valid.^3];

            strKoop = 'Lin + velsqare';% Best performance T2, T1: 83.777, 96.645, model states 84

        end

        n = size(states,1);
        r = min(r,n);%define truncation level for Singular Value Decomposition

        f = '';
        plotView = 0; plotOn = 0;
        [sys_red,FITje,U,S,V,method,X,X_p,Xd,dirdmd,xstates]=dynamicmodedecomposition(states,Inputs, Outputs, Deterministic,method,r,maindir,f,dt,plotView,plotOn);
        % save(strcat(dirdmd,'/OPTIONS.mat'),'detrendingstates','method','koopman','rho','D','dt','dirName','dirName_val');


        %% (3) DATA VALIDATION
        % Validate Models from validation data set
        [FITje_val,dirdmd_val,xstatesvalid] = validatemodels(sys_red,Inputs_val,Outputs_val,r,strcat(dirdmd, '/val'),f,statesvalid,U,Deterministic_val,method,plotView,plotOn);
        % save(strcat(dirdmd,'/FIT.mat'),'FITje_val','FITje');

        %
        [a,b] = max(FITje_val(2,1:r)); %best performing model, only analysing first 50
        [a1,b1] = max(FITje_val(1,1:r)); %#ok<ASGLU> Might be used at some point
        [aId,b1] = max(FITje(2,1:r)); %#ok<ASGLU> %best performing model, only analysing first 50
        [a1Id,b1] = max(FITje(1,1:r));

        fprintf('Best performance T2, T1: %2.3f, %2.3f, model states %d\n', a, FITje_val(1,b),b);

        purpose = ''; xStr = '';
        OMEGA = ''; DAMPING = '';
        plotView = 0; plotOn =0;
        %sys_red,si,Inputs, Outputs,FITje,OMEGA,DAMPING,purpose,x,states,U,Deterministic,method
        [~,~,~,~,~,ysim_val] = evaluatemodel(sys_red,b,Inputs_val,Outputs_val,FITje_val,OMEGA,DAMPING,purpose,xStr,statesvalid,U,Deterministic_val,method,plotView,plotOn);
        %plot(Outputs(1,1:end-1) + Outputs(2,1:end-1)) ; hold on; plot(ysim_val(:,1) + ysim_val(:,2));
        [~,~,~,~,~,ysim] = evaluatemodel(sys_red,b,Inputs_val,Outputs,FITje,OMEGA,DAMPING,purpose,xStr,...
            states,U,Deterministic,method,plotView,plotOn);

        plotStruct{idx}.Outputs_val = Outputs_val; %#ok<*SAGROW>
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
    % Save to matfile:
    if length(koopmanVec) >= 4
        save(aMatFullfilename,'plotStruct');
    end
end

%% calculate the RMSE
simPwr1 = plotStruct{1}.Outputs_val(1,1:end-1) * scalingfactors(1) + meanvalues(1);
simPwr2 = plotStruct{1}.Outputs_val(2,1:end-1) * scalingfactors(2) + meanvalues(2);
simPwrRef = (simPwr1 + simPwr2)/10^6;

RMSEvec = nan(length(koopmanVec),1);
for idx = 1:length(koopmanVec)
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

fprintf(fid,'Data subset & Lifting functions & States \\zeta & Selected States \\tilde{\\zeta} & VAF(P_1) & VAF(P_2) & NRMSE \n');

for idx = 1 : length(plotStruct)
    % fprintf('%s\n',plotStruct{idx}.legStrAllId);
    % fprintf('%s\n',plotStruct{idx}.legStrAll);

    aStruct = plotStruct{idx};
    aStructCell = regexp(aStruct.legStrAll,';','split');
    matches = regexp(aStruct.legStrAllId, '(\d+\.\d+)(?=%)', 'match');
    vaf_values = str2double(matches);
    fprintf(fid, '%s & %s &  %d & %d & %2.2f\\ & %2.2f\\%% & %2.2f\\%% \n', aStructCell{1}, aStructCell{2}, ...
        aStruct.noState, aStruct.noStateVAF, aStruct.a1, aStruct.a, NRMSE_pct(idx));

end
fclose(fid);

fprintf('Results in mat file: %s\n',aMatFullfilename)
fprintf('Printed to txt file: %s\n',aTextFile)


%% (6) MODEL PREDICTIVE CONTROL DESIGN

% modeltouse = b;
% freq=1/dt;
% lpf=ss(freq, 1,freq,0,2);
% sys_red_fil=series(lpf, sys_red{modeltouse});
%
% mpcmodel = sys_red_fil;
% Hp = 600;
% Hc = 600;
% Inputs = Inputs_val;
% Outputs = Outputs_val;
% %scalingfactors = scalingfactors; dirdmd = dirdmd;
% qq = 1000;
% rr = 0.01;
% tic; [u,predictedpower,Pref]=power_referencetracking(mpcmodel,Hp,Hc,Inputs,Outputs,scalingfactors,dirdmd,qq,rr); toc
%
%
%
% % t = 1:dt:length(plotStruct{idx}.Outputs_val)*dt;
% %
% % fs = 12;
% % figure; plot(t,sum(plotStruct{idx}.Outputs_val),t,sum(plotStruct{idx}.ysim_val')');
% % grid on;
% %
% %   xlabel('Time (s)','FontSize',fs)
% %   ylabel(' \delta Power (MW)','FontSize',fs)
% % legend('Real',plotStruct{idx}.legStr,'Location','northoutside')
%
%
