function [Inputs, Outputs, Deterministic] = preprocessdmdval(beg, rotSpeed,time1,rotorAzimuth,nacelleYaw,pitchmode, pitch,scalingfactors,powerGenerator,rho,meanvalues)

%% EVALUATE RELEVANT STATES TO BE UED 
%% DETERMINISTIC STATES
% X1=detrend(rotSpeed(end-beg*10:1:end,1)');
% X2=detrend(rotSpeed(end-beg*10:1:end,2)');
% 
% [X1] = resampleedgeeffect(X1,10); %rotor speed of turbine 1 as first output
% [X2] = resampleedgeeffect(X2,10); %rotor speed of turbine 2 as second output
% X1=resample(detrend(rotSpeed(end-750*10:1:end,1)'),1,10);
% X2=resample(detrend(rotSpeed(end-750*10:1:end,2)'),1,10);
% X3=resample(detrend(rotSpeed(end-750*10:1:end,1)'),1,10).^2;
% X4=resample(detrend(rotSpeed(end-750*10:1:end,2)'),1,10).^2;
 meanX1 = meanvalues(4); %7.201 -> 6.9939
 X1temp = (rotSpeed(end-beg*10:1:end,1) - meanX1)/scalingfactors(4);
 meanX2 = meanvalues(5); %3.67 -> 4.6889
 X2temp = (rotSpeed(end-beg*10:1:end,2) - meanX2)/scalingfactors(5);
 
 [X1] = resampleedgeeffect(X1temp,10); 
 [X2] = resampleedgeeffect(X2temp,10);
 
Deterministic=[X1; X2]; 




%% OUTPUTS
%the rotor speeds of the two turbines are defined as outputs of the wind turbine system 
%POWER OUTPUT
   % meanY1=5.485*10^6;%pitch 0
   meanY1 = meanvalues(1);% 5.352*10^6; %yaw -10 -> 6.1835e+06   
   Y1temp = (powerGenerator(end-beg*10:1:end,1) - meanY1)/scalingfactors(1);
    
  % meanY2=0.7728*10^6; %pitch 0
   meanY2 = meanvalues(2); %0.9512*10^6; %yaw -10 -> meanvalues(2)
   %meanY2=mean(powerGenerator(300:500,2));
   Y2temp = (powerGenerator(end-beg*10:1:end,2) - meanY2)/scalingfactors(2);
% 
  [Y1] = resampleedgeeffect(Y1temp,10); %rotor speed of turbine 1 as first output
  [Y2] = resampleedgeeffect(Y2temp,10);

Outputs=[Y1;Y2];

%% INPUTS: 
if pitchmode==0

    steadyyaw=260;
    %U1=detrend(nacelleYaw(end-beg*10:1:end,1)');
    nacelleYaw1 = nacelleYaw(end-beg*10:1:end,1)';
    U1temp = (nacelleYaw1-steadyyaw)/scalingfactors(3);
    U1 = resampleedgeeffect(U1temp,10);
    Inputs= U1;

elseif pitchmode==1
    
    %% MBC: Multi-Blade Coordinate transformation
%A directional thrust force  can be accomplished by implementinf MBC
%transformation, and decoupling/proejcting the blade loads in a non
%-rotating reference frame

% As a result, the measured out-of plane blade root bending moments M(t)
% --> [pitch{ij}(index,1);pitch{ij}(index,2);pitch{ij}(index,3)] are
% projected onto a non rotating reference frame --> PITCH 

    Nturb=2;
    Offset=-8.4*2; 

    for index=1:1:length(time1)
        %for each time instant INDEX get (for each turbine ij below) the 3
        %out-of-plane blade root bending moments, corresponding to the
        %three columns given a certain line
       
        for ij=1:1:Nturb
            
            Azimuth=rotorAzimuth(index,ij);

            PITCH=([1/3 1/3 1/3;
                        2/3*cosd(Azimuth+Offset) 2/3*cosd(Azimuth+120+Offset) 2/3*cosd(Azimuth+240+Offset);  
                        2/3*sind(Azimuth+Offset) 2/3*sind(Azimuth+120+Offset) 2/3*sind(Azimuth+240+Offset);])*...
                    [pitch{ij}(index,1);pitch{ij}(index,2);pitch{ij}(index,3)];         
                
            Pitch1(ij)=PITCH(1);
            Pitch2(ij)=PITCH(2);
            Pitch3(ij)=PITCH(3);
            
            %3 Matrixes containing the different bending moments where each
            %line has the turbine number and each column the time instant
            %INDEX
            PPitch1(ij,index)=PITCH(1);
            PPitch2(ij,index)=PITCH(2);
            PPitch3(ij,index)=PITCH(3);

        end
    end
    
%     U1=resample(detrend(PPitch2(1,end-750*10:1:end)),1,10);
%     U1=U1./scalingfactors(3);
%     U2=resample(detrend(PPitch3(1,end-750*10:1:end)),1,10);
%     U2=U2./scalingfactors(4);
%     Inputs= [U1; U2];

    U1=PPitch1(1,end-beg*10:1:end);
    [U1] = resampleedgeeffect(U1,10);
    Inputs= [U1];
    
end
    

%%%
% Y1=resample(detrend(powerGenerator(end-750*10:1:end,1)*1e-6'),1,10);
% Y2=resample(detrend(powerGenerator(end-750*10:1:end,2)*1e-6'),1,10);

% X3=X1.^2;
% X4=X2.^2;

%X3=X3./scalingfactors(6);
%X4=X4./scalingfactors(7);

% X3=resample(rotSpeed(end-beg*10:1:end,1),1,10).^2;
% X4=resample(rotSpeed(end-beg*10:1:end,2),1,10).^2;
% X3=X3./var(X3);
% X4=X4./var(X4);