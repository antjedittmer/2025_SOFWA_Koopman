function visualizeVAF2(idx0,plotStruct,matFile1)    

if ~nargin
    
    idx0 = 1;
    figure(42)
    legStr = 'legStrAll';
    load('simAll0_plotStruct.mat','plotStruct');
    matFile1 = 'simAll1_plotStruct_resampledOriginal.mat'; 
else
    legStr = sprintf('legStr%d',idx0);
end


simPwr =  plotStruct{1}.Outputs_val(idx0,1:end-1);
dT =2;
t = 1:dT: length(simPwr)*dT;

plot(t,simPwr,'color',0.5 *ones(1,3),'LineWidth',1.5) ; hold on;

leg{1} = 'Simulated power SOFWA verification data';

cl1 = {[0,0,1]; [0,0.8,0];[0,0.4,0]};
ls = {'-','--','-.',':'};
lw = 0.75;

vec = [1,2,4];

for sidx = 1:3 % length(plotStruct)
    idx = vec(sidx);
    simPwr = plotStruct{idx}.ysim_val(1:end-1,idx0);
    plot(t,simPwr,'color', cl1{sidx},'linestyle',ls{sidx},'LineWidth',lw); % idx/2*[0,0,1]) ; hold on;
    leg{sidx + 1} = plotStruct{idx}.(legStr);

end

%load('simAll1_plotStruct.mat','plotStruct');
load(matFile1,'plotStruct');

nleg = length(leg);

cl1 = {[1,0,0]; 0*[1,1,1]; [1,0,1]};

vec = [1,2,length(plotStruct)];
for sidx = 1: 3 % length(plotStruct)
    idx = vec(sidx);
    simPwr =  plotStruct{idx}.ysim_val(1:end-1,idx0);
    plot(t,simPwr,'color', cl1{sidx},'linestyle',ls{sidx}); % idx/2*[0,0,1]) ; hold on;
    leg{sidx + nleg} = plotStruct{idx}.(legStr);
end

fs = 12;

axis tight; grid on;

strLeg = sprintf('Power T%d (MW)',idx0);
ylabel(['\delta ',strLeg],'Fontsize',fs)

if ~nargin
    legend(leg,'Location','northoutside','Fontsize',fs-1);
    xlabel('Time (s)','Fontsize',fs)

    figDir = pwd;
    strFig = sprintf('PowerEstSofwa%d',idx0);
    print(fullfile(figDir,strFig), '-dpng');
    print(fullfile(figDir,strFig), '-depsc');
end

%legend(leg)
