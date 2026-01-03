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

plot3D = 0;

vectempx = 1:550;
vectempy = 1:111;
vectempz = 1:99;

vecx = vectempx(1:4:end);
vecy = vectempy(1:4:end);
vecz = vectempz(1:4:end);

lx = length(vecx);
% x: Length: 1710m: 138 samples, delta samples 12.39 m
% 5D = 178 *5: Position
ly = length(vecy);
lz = length(vecz);
l = lx*ly*lz;

if plot3D == 1
    lent=size(QQ_u,2);

    qq_u4d = reshape(QQ_u,ly,lx,lz,lent);
    qq_v4d = reshape(QQ_v,ly,lx,lz,lent);

    % qq_u4d = reshape(QQ_u,YY,XX,ZZ,lent);
    posT = 178*5/1710 * 138;

    timeVec = [50,100,200];
    zT = - 1: 11;
    zT2 = -4 : 3;
    yT = 0: (ly-1);

    [ZT,YT] = meshgrid(zT,yT);
    [ZT2,YT2] = meshgrid(zT2,yT);

    XT = posT *ones(size(ZT));
    XT2 = posT *ones(size(ZT2));

    CO(:,:,1) = ones(size(YT)); % red
    CO(:,:,2) = zeros(size(YT)); % green
    CO(:,:,3) = zeros(size(YT));% blue

    CO1(:,:,1) = ones(size(YT2)); % red
    CO1(:,:,2) = zeros(size(YT2)); % green
    CO1(:,:,3) = zeros(size(YT2));% blue


    for idx = 1: length(timeVec)
        aTime = timeVec(idx);

        figure(idx+3)
        subplot(2,1,1)
        surfc(qq_u4d(:,:,10,aTime));
        hold on;
        mesh(XT,YT,ZT,CO);
        view(1,48)
        title(sprintf('Wind u at time %d, turbine 2 at 5D = 890',aTime));

        subplot(2,1,2)
        surfc(qq_v4d(:,:,10,aTime));
        hold on;
        mesh(XT2,YT2,ZT2,CO1);
        title(sprintf('Wind v at time %d, turbine 2 at 5D = 890',aTime));
        view(1,48)

    end

else

    xx = x(1:4:end); % vecx;
    yy = y(1:4:end); % vecy;
    zz = z(1:4:end); % vecz;

    Xsel1 = 1:(length(xx)-55); % For quiver field
    Ysel1 = 1:(length(yy)-1); % 1:28
    Zsel1 = 1:23;

    if length(QQ_u) == 51543

        yy = yy(1:1:end-1); %yaw
        xx = xx(1:1:end-55); %yaw
        zz = zz(1:1:23); %yaw
    end

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

end
return;

% c = colorbar();drawnow
%     alphaVal = 0.25;
%     cdata = c.Face.Texture.CData;  % Get the color data of the object that correponds to the colorbar
%     cdata(end,:) = uint8(alphaVal * cdata(end,:)); % Change the 4th channel (alpha channel) to 10% of it's initial value (255)
%     c.Face.Texture.ColorType = 'truecoloralpha'; % Ensure that the display respects the alpha channel
%     c.Face.Texture.CData = cdata;  % Update the color data with the new transparency information



figure(1),surfc(qq_u4d(:,:,1,500));
xlabel('X(1 point =4m)')
ylabel('Y(1 point =4m)')
zlabel('Wind velocity')
title('z=4m,time step 500sec')
figure(2),surfc(qq_u4d(:,:,1,700));
figure(3),surfc(qq_u4d(:,:,12,500));
xlabel('X(1 point =4m)')
ylabel('Y(1 point =4m)')
zlabel('Wind velocity')
title('z=4m,time step 500sec')

% z_dot75 = round(size(qq_u4d,3)*0.75); %17
% figure(4),surfc(qq_u4d(:,:,z_dot75,500));
%round(ZZ*0.25);
%figure(5),surfc(qq_u4d(:,:,round(ZZ*0.25),500));

%qq_u4d=NaN(lx,ly,lz,size(QQ_u(2)))