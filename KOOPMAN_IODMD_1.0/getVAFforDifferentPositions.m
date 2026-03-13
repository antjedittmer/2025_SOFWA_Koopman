function VAF_P2 = getVAFforDifferentPositions(Xsel)

if ~nargin
    Xsel = [1,70]; %[1,10,50,70];
end

maindir = [pwd,'/matlab_code_tests/'];

%DataIn = fullfile(parentdir,'data');

pitchmode = 0; %0 for wake redirection control (yaw) and 1 for axial induction control (pitch)

analysis ='YAW_MPC_offset_test'; %name of directory to be created to automatically store results
filename ='yaw_control/U_data_complete_vec_yaw_off.mat'; %directory for matlab file with flow field identification data set
filenamevalid ='yaw_control/U_data_complete_vec_yaw_off_val.mat'; %directory for matlab file with flow field validation data set

%detrendingstates = 1; %1 to take mean flow and consider turbulent fluctuations
method = 3; %0: DMD ; 1:DMDc; 2:IODMD; 3:EIODMD
% videos = 0; %generate videos
% snapshots = 0; %generate snapshots from simulation data
%retakePoint = 2;
r = 100;

% Turbine and flow characteristics to be used
rho = 1.225; %air density in [kg m^-3]
%D = 178; %Rotor Diameter used in simulations: 178 [m]
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
load('DataSetTurbineUsed.mat','rotSpeed*','nacelleYaw*','time1*','rotorAzimuth*','pitch*','powerGenerator*');

%% Retake points
[~,~,~,~,~,~,QQ_u1] = retakepoints_at_turbine(QQ_u,x,y,z,Decimate,Xsel);
[xxx,yyy,zzz,XX,YY,ZZ,valid.QQ_u1] = retakepoints_at_turbine(valid.QQ_u,x,y,z,Decimate,Xsel);

[~,~,~,~,~,~,QQ_v1] = retakepoints_at_turbine(QQ_v,x,y,z,Decimate,Xsel);
[~,~,~,~,~,~,QQ_w1] = retakepoints_at_turbine(QQ_w,x,y,z,Decimate,Xsel);

[~,~,~,~,~,~,valid.QQ_v1] = retakepoints_at_turbine(valid.QQ_v,x,y,z,Decimate,Xsel);
[~,~,~,~,~,~,valid.QQ_w1] = retakepoints_at_turbine(valid.QQ_w,x,y,z,Decimate,Xsel);


%
% %easy solution to augment u flow field data matricx with other flow
% %field data instead of using koopmanextension function
% QQ_u1 = [double(QQ_u1);double(QQ_v1)]; %double(QQ_w1)
% valid.QQ_u1 = [double(valid.QQ_u1);double(valid.QQ_v1)]; %double(valid.QQ_w1) %perform same

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

[states1all,~,scalingfactor] = preprocessstates(states0); %remove meanflow or other pre-processing techniques to experiment
[statesvalid1all]=preprocessstates(statesvalid0,scalingfactor);

noStateUV = 1/3 *size(states1all,1); %u and v selected
   
states1 = states1all(1:noStateUV,:);
statesvalid1 = statesvalid1all(1:noStateUV,:);


%% (2) DYNAMIC MODE DECOMPOSITION

% Process validation data
[Inputs, Outputs, Deterministic,scalingfactors,meanvalues] = preprocessdmdid(beg, rotSpeed,time1,rotorAzimuth,nacelleYaw, pitchmode,pitch,powerGenerator,rho); %preprocess information (resample, and maintain only relevant data)
[Inputs_val, Outputs_val, Deterministic_val] = preprocessdmdval(beg, rotSpeed_val,time1_val,rotorAzimuth_val,nacelleYaw_val,pitchmode,pitch_val,scalingfactors,powerGenerator_val,rho,meanvalues); %preprocess information (resample and only relevant data)


%% Start loop over
% states1 = Deterministic;
% statesvalid1 = Deterministic_val;
%noStateUV = 1/3 *size(states1,1); %u and v selected
states= [states1; states1.^2; states1.^3]; %[states_u; states_u.^2; statesvalid_u.^3];
statesvalid = [statesvalid1; statesvalid1.^2; statesvalid1.^3];

n = size(states,1);
r = min(r,n); %define truncation level for Singular Value Decomposition

f = '';
plotView = 0; plotOn = 0;
[sys_red,~,U,~,~,method,~,~,~,dirdmd,~]=dynamicmodedecomposition(states,Inputs, Outputs, Deterministic,method,r,maindir,f,dt,plotView,plotOn);

%% (3) DATA VALIDATION
% Validate Models from validation data set
[FITje_val] = validatemodels(sys_red,Inputs_val,Outputs_val,r,strcat(dirdmd, '/val'),f,statesvalid,U,Deterministic_val,method,plotView,plotOn);
VAF_P2 = max(FITje_val(2,1:r)); %best performing model, only analysing first 50
