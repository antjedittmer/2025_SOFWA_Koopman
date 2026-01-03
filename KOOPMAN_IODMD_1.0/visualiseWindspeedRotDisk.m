close all;

if exist('QQ_u','var') ~= 1
    parentDir = fileparts(pwd);
    filename = 'data/yaw_control/U_data_complete_vec_yaw_off.mat'; %directory for matlab file with flow field identification data set
    load(fullfile(parentDir,filename));
end

figDir = fullfile(pwd,'figDir');

if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

xLen = length(x); yLen = length(y);  zLen = length(z);
xx = x(1:4:xLen); % vecx;
yy = y(1:4:yLen); % vecy;
zz = z(1:4:zLen); % vecz;

Xsel1 = 1:(length(xx)-55); % For quiver field
Ysel1 = 1:(length(yy)-1); % 1:28
Zsel1 = 1:23;

Y = length(yy);
X = length(xx);
Z = length(zz);

Xsel = [1,70];%1:130;%
Ysel = 7:22;%1:28;%
Zsel = 10;

zH = Zsel;

[Xm_shs,Ym_shs,Zm] = meshgrid(xx-500,(yy-500), zz);

i = 500;
UmeanAbs_sh_u = reshape(double(QQ_u(:,i)),Y,X,Z);
UmeanAbs_sh_v = reshape(double(QQ_v(:,i)),Y,X,Z);
UmeanAbs_sh_w = reshape(double(QQ_w(:,i)),Y,X,Z);

% figure;
% quiver3(Ym_shs,Xm_shs,Zm,UmeanAbs_sh_v,UmeanAbs_sh_u,UmeanAbs_sh_w);

UmeanAbs_sh_u2D = UmeanAbs_sh_u(:,:,zH);
UmeanAbs_sh_v2D = UmeanAbs_sh_v(:,:,zH);
Xm_shs_2D = Xm_shs(:,:,zH);
Ym_shs_2D = Ym_shs(:,:,zH);
Vmean = (UmeanAbs_sh_u2D.^2 + UmeanAbs_sh_v2D.^2).^(1/2);


%% long/lateral wind at hub height
figure(1); %contourf(Xm_shs_2D,Ym_shs_2D,Vmean,"FaceAlpha",0.25);

fs = 13;
contourf(Xm_shs_2D,Ym_shs_2D,Vmean); colormap('sky'); hold on;
Xm_shs_2D1 = Xm_shs_2D(Ysel1,Xsel1);
Ym_shs_2D1 = Ym_shs_2D(Ysel1,Xsel1);
UmeanAbs_sh_u2D1 =  UmeanAbs_sh_u2D(Ysel1,Xsel1);
UmeanAbs_sh_v2D1 = UmeanAbs_sh_v2D(Ysel1,Xsel1);
quiver(Xm_shs_2D1,Ym_shs_2D1,UmeanAbs_sh_u2D1,UmeanAbs_sh_v2D1,'k')

posDefault = get(0,'DefaultFigurePosition');
set(gcf, 'position', [posDefault(1) - posDefault(3)*0.7,posDefault(2),posDefault(3)*3.1,posDefault(4)]);
xlabel('x (m)','FontSize',fs); ylabel('y (m)','FontSize',fs);

Xm_shs_2Dsel = Xm_shs_2D(Ysel,Xsel);
Ym_shs_2Dsel = Ym_shs_2D(Ysel,Xsel);
UmeanAbs_sh_u2Dsel =  UmeanAbs_sh_u2D(Ysel,Xsel);
UmeanAbs_sh_v2Dsel = UmeanAbs_sh_v2D(Ysel,Xsel);

quiver(Xm_shs_2Dsel,Ym_shs_2Dsel, UmeanAbs_sh_u2Dsel,UmeanAbs_sh_v2Dsel,...
    'r','AutoScaleFactor',0.2);

legend('Wind contour hub height (m/s)','Wind field data points (m/s)','Wind at turbines data points (m/s)')
set(findall(gcf,'-property','FontSize'),'FontSize',13.5)
axis equal;


colorbar();drawnow

strFig = 'WindData';
print(fullfile(figDir,[strFig,'_x']), '-dpng');
print(fullfile(figDir,[strFig,'_x']), '-depsc');


for idxT = 1:2
    aSel = Xsel(idxT);
    strIdxT = num2str(idxT);
    UmeanAbs_sh_u2Dcell.T1 = squeeze(UmeanAbs_sh_u(:,aSel,:));
    UmeanAbs_sh_v2Dcell.T1 = squeeze(UmeanAbs_sh_v(:,aSel,:));
    UmeanAbs_sh_w2Dcell.T1 = squeeze(UmeanAbs_sh_w(:,aSel,:));
    Ym_shs_2Dcell.T1 = squeeze(Ym_shs(:,aSel,:));
    Zm_shs_2Dcell.T1 = squeeze(Zm(:,aSel,:));
    Vmeancell.T1 = (UmeanAbs_sh_u2Dcell.T1.^2 + UmeanAbs_sh_v2Dcell.T1.^2 + UmeanAbs_sh_w2Dcell.T1.^2).^(1/2);

    figure(idxT + 1);
    contourf(Ym_shs_2Dcell.T1,Zm_shs_2Dcell.T1,Vmeancell.T1);
    colormap('sky'); hold on;

    Ym_shs_2Dcell.T11 = Ym_shs_2Dcell.T1(Ysel1,Zsel1);
    Zm_shs_2Dcell.T11 = Zm_shs_2Dcell.T1(Ysel1,Zsel1);
    UmeanAbs_sh_v2Dcell.T11 =  UmeanAbs_sh_v2Dcell.T1(Ysel1,Zsel1);
    UmeanAbs_sh_w2Dcell.T11 = UmeanAbs_sh_w2Dcell.T1(Ysel1,Zsel1);

    quiver(Ym_shs_2Dcell.T11,Zm_shs_2Dcell.T11,...
        UmeanAbs_sh_v2Dcell.T11,UmeanAbs_sh_w2Dcell.T11,'k')
    axis equal;

    Zm_shs_2Dsel_cell.T1 = Zm_shs_2Dcell.T1(Ysel,Zsel);
    Ym_shs_2Dsel_cell.T1 = Ym_shs_2Dcell.T1(Ysel,Zsel);
    UmeanAbs_sh_v2Dsel_cell.T1 = UmeanAbs_sh_v2Dcell.T1(Ysel,Zsel);
    UmeanAbs_sh_w2Dsel_cell.T1 = UmeanAbs_sh_w2Dcell.T1(Ysel,Zsel);

    quiver(Ym_shs_2Dsel_cell.T1,Zm_shs_2Dsel_cell.T1, ...
        UmeanAbs_sh_v2Dsel_cell.T1,UmeanAbs_sh_w2Dsel_cell.T1,...
        'r','AutoScaleFactor',0.75);
    xlabel('y (m)','FontSize',fs); ylabel('z (m)','FontSize',fs);
    colorbar(); drawnow;

    legend(['Wind contour WT',strIdxT,' (m/s)'],'Wind field data (m/s)', ['Wind at WT',strIdxT,' data (m/s)'])
    set(findall(gcf,'-property','FontSize'),'FontSize',13.5)
    axis equal;

    strFig = 'WindData';
    print(fullfile(figDir,[strFig,'_T',num2str(idxT)]), '-dpng');
    print(fullfile(figDir,[strFig,'_T',num2str(idxT)]), '-depsc');

end


%Unused code
% if length(QQ_u) == 51543
%     yy = yy(1:1:end-1); %yaw
%     xx = xx(1:1:end-55); %yaw
%     zz = zz(1:1:23); %yaw
% end
