function [FITje,OMEGA,DAMPING,fig1,x,ysim_val]=evaluatemodel(sys_red,si,Inputs, Outputs,FITje,OMEGA,DAMPING,purpose,x,states,U,Deterministic,method,plotView,plotOn)

%Def: function that evaluates a given ROM

%Input arguments:
    %1 sys_red: cell array containing all state space reduced order models
    %2 si: index to access the ROMw within each entry of the cell array, representing the number of singular values that were used in the complete SVD
    %4 Inputs: Input data matrix (in this case a vector) used for linear simulation of ROM and may be used for initial state estimation
    %5 Outputs: Output data matrix used for model accuracy quantification and may be used for initial state estimation
    %6 FITje: matrix containing the accuracy of the model measured by the VAF of the outputs. Has dimensions of 2xsi, 2 outputs for each model
    %7 OMEGA: natural frequency
    %8 DAMPING:
    %9 purpose: identification or validation, athough the code should be similar
    %10 x: cell array containing the state space trajectory for a certain ROM.
    %11 Used later for wake reconstruction
    %12 states: snapshot data matrix
    %13U: left isngular vectors with POD mdoes used estimation of initial state
    %Deterministic: Deterministic data matrix
    %method: differentiaing extended (with deterministic states )and non extended data matrix
    
%Output arguments:
    % FITje: matrix containing the accuracy of the model measured by the VAF of the outputs. Has dimensions of 2xsi, 2 outputs for each model
    % OMEGA: 
    % DAMPING:
    %fig1:
    %x: cell array with simulated state space trajetories from each ROM
    
%log:
    %0. first commit October 2020
    %1. function revised and comments added
   
%%

if nargin < 14
    plotView = 0;
end

if nargin < 15
    plotOn = 1;
end


dN = 2; %sample time used for all ROMs
a = strcmp(purpose, 'identification');

if a
    if method ==2
       % [xo]=dinit(sys_red{si}.A,sys_red{si}.B,sys_red{si}.C,sys_red{si}.D,[Inputs]',[Outputs]');
         xo=U(1:size(states,1),1:si)'*states(:,1);
    elseif method==3
        xo=U(1:size(states,1),1:si)'*states(:,1);
        xo=[Deterministic(:,1);xo];
    end
    
    
    %% VARIANCE ACCOUNTED FOR IN THE MODEL FOR IDENTIFICATION DATA
    %time response of dynamic system based on (1) derived state space
    %model (2) system inputs (3) computed initial conditions 
    [ysim, t, xout]=lsim(sys_red{si}, [Inputs]',[],xo);  
    x{si}=xout;

    %compute the variance accounted for in the model based on simualton
    %of model and real output (for each time instant
    %FITje(:,si)=vaf(ysim,[Outputs]');
    FITje(:,si)=vaf([Outputs]',ysim);
  

    %% GRAPHICAL VISUALISAITON OF MODEL PREDICTION AND TRUE SIMULATION (IDENTIFICATION) RESULTS
    if plotOn
        fig1 = figure(1000+si);
        set(gcf,'color','w','Position', get(0, 'Screensize'),'Visible',plotView);
        subplot(2,1,1)
        plot([Outputs(1,1:end-1);]','b','LineWidth',1.6'); %ploting first output fromsimulation
        hold on;
        plot(ysim(:,1),'Color',[0, 0.5, 0.0],'LineWidth',1.6,'LineStyle','--') %ploting first output from model
        xlim([0 size(ysim,1)])
        grid on
        xlabel('Time instant [k]','FontSize',20,'FontName','Times')
        ylabel(' \delta Power [MW]','FontSize',20,'FontName','Times')
        title(['Model fitness: generator power for first turbine. VAF of ',num2str(round(FITje(1,si),2)),' %. '],'FontSize',22,'FontName','Times','FontWeight','Normal')
        legend({'Generator Power SOWFA','ROM Output'},'Location','best','Orientation','vertical','FontSize',18,'FontName','Times')
        legend('boxoff')
        get(gca,'fontname')  % shows you what you are using.
        set(gca,'fontname','times')  % Set it to times

        subplot(2,1,2)
        plot([Outputs(2,1:end-1)]','b','LineWidth',1.6'); %1
        hold on;
        plot(ysim(:,2),'Color',[0, 0.5, 0],'LineWidth',1.6,'LineStyle','--') %3
        xlim([0 size(ysim,1)])
        grid on
        xlabel('Time instant [k]','FontSize',20,'FontName','Times')
        ylabel(' \delta Power [MW]','FontSize',20,'FontName','Times')
        title(['Model fitness: generator power for second turbine. VAF of ',num2str(round(FITje(2,si),2)),' %. '],'FontSize',22,'FontName','Times','FontWeight','Normal')
        legend({'Generator Power SOWFA','ROM Output'},'Location','best','Orientation','vertical','FontSize',18,'FontName','Times')
        legend('boxoff')
        get(gca,'fontname')  % shows you what you are using.
        set(gca,'fontname','times')  % Set it to times
    else
        fig1 = '';
    end
    
    %% GRAPHICAL VISUALISAITON OF MODEL PREDICTION AND TRUE SIMULATION (VALIDATION) RESULTS
else
    
     %[xo_val]=dinit(sys_red{si}.A,sys_red{si}.B,sys_red{si}.C,sys_red{si}.D,[Inputs]',[Outputs]');
     xo_val = U(1:size(states,1),1:si)'*states(:,1); %use validation data set to estimate initial condition
     
     if method==3
         xo_val = [Deterministic(:,1);xo_val];
     end
     
     [ysim_val, t, xout] = lsim(sys_red{si}, [Inputs]',[],xo_val);  %perform linear simulation

     %FITje(:,si)=vaf(ysim_val,[Outputs]');  
     FITje(:,si) = vaf([Outputs]',ysim_val); %measure VAF between Output of simulation and output from testing data set

     x{si}=xout; %save state space trajectory for wake reconstructions
    
    %visualisation 
    if plotOn
        fig1=figure(2000+si);
        fig1.Visible = plotView;
        set(gcf,'color','w','Position', get(0, 'Screensize'));
        subplot(2,1,1)
        plot([Outputs(1,1:end-1);]','b','LineWidth',1.6'); %1
        hold on;
        plot(ysim_val(:,1),'Color',[0, 0.5, 0],'LineWidth',1.6,'LineStyle','--') %3
        xlim([0 size(ysim_val,1)])
        grid on
        xlabel('Time instant [k]','FontSize',20,'FontName','Times')
        ylabel(' \delta Power [MW]','FontSize',20,'FontName','Times')
        title(['Model fitness: generator power for first turbine. VAF of ',num2str(round(FITje(1,si),2)),' %. '],'FontSize',22,'FontName','Times','FontWeight','Normal')
        legend({'Generator Power SOWFA','ROM Output'},'Location','best','Orientation','vertical','FontSize',18,'FontName','Times')
        legend('boxoff')
        get(gca,'fontname')  % shows you what you are using.
        set(gca,'fontname','times')  % Set it to times

        subplot(2,1,2)
        plot([Outputs(2,1:end-1)]','LineWidth',1.6'); %1
        hold on;
        plot(ysim_val(:,2),'Color',[0, 0.5, 0],'LineWidth',1.6,'LineStyle','--') %3
        grid on
        xlim([0 size(ysim_val,1)])
        xlabel('Time instant [k]','FontSize',20,'FontName','Times')
        ylabel(' \delta Power [MW]','FontSize',20,'FontName','Times')
        title(['Model fitness: generator power for second turbine. VAF of ',num2str(round(FITje(2,si),2)),' %. '],'FontSize',22,'FontName','Times','FontWeight','Normal')
        legend({'Generator Power SOWFA','ROM Output'},'Location','best','Orientation','vertical','FontSize',18,'FontName','Times')
        legend('boxoff')
        get(gca,'fontname')  % shows you what you are using.
        set(gca,'fontname','times')  % Set it to times

% figure; plot(Outputs(1,1:end-1) + Outputs(2,1:end-1)) ; hold on; plot(ysim_val(:,1) + ysim_val(:,2));

    else
        fig1 = '';
    end 

end

