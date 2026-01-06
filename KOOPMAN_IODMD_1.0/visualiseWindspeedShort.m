clear; close all;

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
% x: Length: 1710m: fs + 18 samples, delta samples fs.39 m
% 5D = 178 *5: Position
ly = length(vecy);
lz = length(vecz);
l = lx*ly*lz;


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

Xsel = [1,70,10,50];%1:fs + 10;%
Ysel = 4: 24; %7:22;%1:28;%
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

Xm_shs_2D1 = Xm_shs_2D(Ysel1,Xsel1);
Ym_shs_2D1 = Ym_shs_2D(Ysel1,Xsel1);
U_u1 =  UmeanAbs_sh_u2D(Ysel1,Xsel1);
U_v1 = UmeanAbs_sh_v2D(Ysel1,Xsel1);

Xm_shs_2Dsel = Xm_shs_2D(Ysel,Xsel);
Ym_shs_2Dsel = Ym_shs_2D(Ysel,Xsel);
U_usel = UmeanAbs_sh_u2D(Ysel,Xsel);
U_vsel = UmeanAbs_sh_v2D(Ysel,Xsel);


%% Plan View (X-Y Plane) at Hub Height
figure(1);
fs = 15;
% Set exactly the same window size as your slices for font/scale consistency
set(gcf, 'Position', [100, 100, 1800, 450]); 

% Use tiledlayout with 'none' padding to maximize the plot area
t1 = tiledlayout(1, 1, 'TileSpacing', 'none', 'Padding', 'none'); 
nexttile;

% 1. Plot the Wind Contour (Truth)
% Use 'LineStyle', 'none' to match the look of the slices
contourf(Xm_shs_2D, Ym_shs_2D, Vmean, 20, 'LineStyle', 'none'); 
colormap('sky'); 
clim([2 9.5]); % Standardized color range
hold on;

% 2. Plot Dense Wind Field Data Points (Black)
quiver(Xm_shs_2D1, Ym_shs_2D1, U_u1, U_v1, 'k', 'LineWidth', 0.5);

% 3. Plot Sparse Measurement Points (Red)
hSparse = quiver(Xm_shs_2Dsel, Ym_shs_2Dsel, U_usel, U_vsel, ...
    'r', 'AutoScaleFactor', 0.2, 'LineWidth', 1.2);

% --- Tighten Formatting ---
axis equal; 
axis tight; % Removes lateral white space
grid on;
xlabel('x (m)', 'FontSize', fs + 1); 
ylabel('y (m)', 'FontSize', fs + 1);

% Targeting the tick labels specifically
set(gca, 'FontSize', fs);

% Shared Legend (Bottom center to match horizontal slices style)
lgd = legend('Wind contour hub height (m/s)', ...
             'Wind field data points (m/s)', ...
             'Sparse wind data points (m/s)'); %, ...
             %'Orientation', 'horizontal', 'Location', 'southoutside');
lgd.FontSize = fs;

% Optional: Add colorbar to match the slices figure
colorbar(); drawnow
set(gca, 'FontSize', fs);

strFig = 'WindData';
print(fullfile(figDir,[strFig,'_x']), '-dpng');
print(fullfile(figDir,[strFig,'_x']), '-depsc');


%% Horizontal Tiled Layout for Cross-Sectional (Y-Z) Views
% Setup figure with a wide aspect ratio for horizontal tiling
figYZ = figure('Position', [100, 100, 1800, 450]); 
t = tiledlayout(1, 4, 'TileSpacing', 'compact', 'Padding', 'tight');

% Common scaling and titles
cRange = [2 9.5]; % Unified wind speed range (adjust to your data)
titles = {'WT1 Rotor', '112.5 m behind WT1', ...
          '612.5 m behind WT1', 'WT2 Rotor'};
p2 = 1;
for idxT = 1:4
    aSel = Xsel(idxT);
    ax = nexttile;
    hold on;
    
    % --- Data Extraction ---
    U_u = squeeze(UmeanAbs_sh_u(:,aSel,:));
    U_v = squeeze(UmeanAbs_sh_v(:,aSel,:));
    U_w = squeeze(UmeanAbs_sh_w(:,aSel,:));
    Y_p = squeeze(Ym_shs(:,aSel,:));
    Z_p = squeeze(Zm(:,aSel,:));
    V_mag = sqrt(U_u.^2 + U_v.^2 + U_w.^2);
    
    % --- 1. Contour Plot (Truth) ---
    contourf(Y_p, Z_p, V_mag, 20, 'LineStyle', 'none');
    colormap(ax, 'sky');
    clim(cRange); % Standardizes colors across all four tiles
    
    % --- 2. Dense Wind Field (Black Quivers) ---
    % Decimating points slightly improves visual clarity in dense grids
    quiver(Y_p(1:p2:end, 1:p2:end), Z_p(1:p2:end, 1:p2:end), ...
           U_v(1:p2:end, 1:p2:end), U_w(1:p2:end, 1:p2:end), 'k', 'LineWidth', 0.5);
    
    % --- 3. Sparse Hub-Height Measurements (Red Quivers) ---
    hSparse = quiver(Y_p(Ysel, Zsel), Z_p(Ysel, Zsel), ...
                     U_v(Ysel, Zsel), U_w(Ysel, Zsel), 'r', ...
                     'AutoScaleFactor', 0.75, 'LineWidth', 1.5);
    
    % --- 4. Rotor Disk Guide ---
    % Adds physical context: 178m Diameter circle centered at hub height (119m)
    th = linspace(0, 2*pi, 100);
    plot(89*cos(th), 89*sin(th) + 119, 'k--', 'LineWidth', 1.2);
    set(gca, 'FontSize', fs);
    
    % --- Formatting ---
    title(titles{idxT}, 'FontSize', fs + 1);
    xlabel('y (m)');
    if idxT == 1
        ylabel('z (m)');
    else
        yticklabels([]); % Remove redundant Y-labels for internal plots
    end
    axis equal; grid on;
    xlim([-170 170]); ylim([0 300]);
end

% --- Shared Colorbar ---
cb = colorbar;
% cb.Layout.Tile = 'east';
% cb.Label.String = 'Wind Speed (m/s)';
cb.FontSize = fs;

% --- Shared Legend (Positioned at bottom) ---
% lgd = legend(hSparse, 'Sparse wind data points (m/s)', ...
%              'Orientation', 'horizontal');
% lgd.Layout.Tile = 'south';
% lgd.FontSize = fs + 1;

% Export final combined figure
strFig = 'WindData_Horizontal_Slices';
print(fullfile(figDir, strFig), '-dpng', '-r300');
print(fullfile(figDir,strFig), '-depsc');



