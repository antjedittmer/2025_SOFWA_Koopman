%% Initialization and Data Loading
clc; %close all;
clearvars -except QQ_u QQ_v QQ_w x y z;

% Check if wind field data (QQ_u) is already in workspace, otherwise load it
if exist('QQ_u','var') ~= 1 || length(QQ_u) ~= 96600
    parentDir = fileparts(pwd);
    % Path to the flow field identification data set (Yaw Off case)
    filename = 'data/yaw_control/U_data_complete_vec_yaw_off.mat'; 
    load(fullfile(parentDir,filename));
end

% Create directory for saving figures
figDir = fullfile(pwd,'figDir');
if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

% Define specific slices and simulated measurement points 
Xsel = [1,10,51,70]; % X-indices: WT1, near wake, far wake, upstream of WT2
Ysel = 4:24;         % Lateral selection for sparse data
Zsel = 10;           % Index for Hub Height
zH = Zsel;

%% Grid Definition and Downsampling
plot3D = 0;
% Define indices for spatial dimensions (X=Streamwise, Y=Lateral, Z=Vertical)
vectempx = 1:550;
vectempy = 1:111;
vectempz = 1:99;

% Subsample the grid for cleaner visualization (every 4th sample)
vecx = vectempx(1:4:end);
vecy = vectempy(1:4:end);
vecz = vectempz(1:4:end);

lx = length(vecx); ly = length(vecy); lz = length(vecz);
l = lx*ly*lz;

% Extract actual coordinate values based on subsampling
xx = x(1:4:end); 
yy = y(1:4:end); 
zz = z(1:4:end); 

% Selection ranges for quiver fields (vector plots)
Xsel1 = 1:(length(xx)-55); 
Ysel1 = 1:(length(yy)-1); 
Zsel1 = 1:23;

Y = length(yy); X = length(xx); Z = length(zz);

% Create 3D meshgrid (shifted by 500m for centering)
[Xm_shs,Ym_shs,Zm] = meshgrid(xx-500,(yy-500), zz);

% Reshape velocity components (u, v, w) for a specific time step (i=500)
i = 500;
UmeanAbs_sh_u = reshape(double(QQ_u(:,i)),Y,X,Z);
UmeanAbs_sh_v = reshape(double(QQ_v(:,i)),Y,X,Z);
UmeanAbs_sh_w = reshape(double(QQ_w(:,i)),Y,X,Z);

% Extract 2D Plane at Hub Height for Plan View
UmeanAbs_sh_u2D = UmeanAbs_sh_u(:,:,zH);
UmeanAbs_sh_v2D = UmeanAbs_sh_v(:,:,zH);
Xm_shs_2D = Xm_shs(:,:,zH);
Ym_shs_2D = Ym_shs(:,:,zH);
Vmean = (UmeanAbs_sh_u2D.^2 + UmeanAbs_sh_v2D.^2).^(1/2); % Magnitude

% Prepare data for Plan View Vektor plots
Xm_shs_2D1 = Xm_shs_2D(Ysel1,Xsel1);
Ym_shs_2D1 = Ym_shs_2D(Ysel1,Xsel1);
U_u1 =  UmeanAbs_sh_u2D(Ysel1,Xsel1);
U_v1 = UmeanAbs_sh_v2D(Ysel1,Xsel1);

Xm_shs_2Dsel = Xm_shs_2D(Ysel,Xsel);
Ym_shs_2Dsel = Ym_shs_2D(Ysel,Xsel);
U_usel = UmeanAbs_sh_u2D(Ysel,Xsel);
U_vsel = UmeanAbs_sh_v2D(Ysel,Xsel);

%% Plot 1: Plan View (X-Y Plane) at Hub Height
figure;
fs = 15; % Font size
set(gcf, 'Position', [100, 100, 1800, 450]); 
t1 = tiledlayout(1, 1, 'TileSpacing', 'none', 'Padding', 'none'); 
nexttile;

% 1. Plot the Wind Contour (Ground Truth)
contourf(Xm_shs_2D, Ym_shs_2D, Vmean, 20, 'LineStyle', 'none'); 
colormap('sky'); clim([2 9.5]); 
hold on;

% 2. Plot Dense Wind Field Data Points (Black Quivers)
quiver(Xm_shs_2D1, Ym_shs_2D1, U_u1, U_v1, 'k', 'LineWidth', 0.5);

% 3. Plot Sparse Measurement Points (Red Quivers - simulating LiDAR/Sensors)
hSparse = quiver(Xm_shs_2Dsel, Ym_shs_2Dsel, U_usel, U_vsel, ...
    'r', 'AutoScaleFactor', 0.2, 'LineWidth', 1.2);

% Formatting
axis equal; axis tight; grid on;
xlabel('x (m)', 'FontSize', fs + 1); ylabel('y (m)', 'FontSize', fs + 1);
set(gca, 'FontSize', fs);

% Legend and Output
lgd = legend('Wind contour hub height (m/s)', ...
             'Wind field data points (m/s)', ...
             'Sparse wind data points (m/s)');
lgd.FontSize = fs;
colorbar(); drawnow;

strFig = 'WindData';
print(fullfile(figDir,[strFig,'_x']), '-dpng');
print(fullfile(figDir,[strFig,'_x']), '-depsc');

%% Plot 2: Horizontal Tiled Layout for Cross-Sectional (Y-Z) Views
figYZ = figure('Position', [100, 100, 1800, 450]); 
t = tiledlayout(1, 4, 'TileSpacing', 'compact', 'Padding', 'tight');

% Titles for different downstream locations
titles = {'WT1 Rotor (index 1)', ...
          sprintf('%2.1f m behind WT1 (index %d)',12.5*(Xsel(2)- 1), Xsel(2)),...
          sprintf('%2.1f m behind WT1 (index %d)',12.5*(Xsel(3)- 1), Xsel(3)), ...
          sprintf('%2.1f m in front of WT2 Rotor (index %d)',890 - 12.5*(Xsel(4)- 1), Xsel(4))};
p2 = 1;

for idxT = 1:4
    aSel = Xsel(idxT); % Select X-position
    ax = nexttile;
    hold on;
    
    % Data Extraction for Y-Z Slices
    U_u = squeeze(UmeanAbs_sh_u(:,aSel,:));
    U_v = squeeze(UmeanAbs_sh_v(:,aSel,:));
    U_w = squeeze(UmeanAbs_sh_w(:,aSel,:));
    Y_p = squeeze(Ym_shs(:,aSel,:));
    Z_p = squeeze(Zm(:,aSel,:));
    V_mag = sqrt(U_u.^2 + U_v.^2 + U_w.^2);
    
    % 1. Contour Plot (Velocity Magnitude)
    contourf(Y_p, Z_p, V_mag, 20, 'LineStyle', 'none');
    colormap(ax, 'sky'); clim([2 9.5]);
    
    % 2. Dense Local Wind Field (Black Quivers)
    quiver(Y_p(1:p2:end, 1:p2:end), Z_p(1:p2:end, 1:p2:end), ...
           U_v(1:p2:end, 1:p2:end), U_w(1:p2:end, 1:p2:end), 'k', 'LineWidth', 0.5);
    
    % 3. Sparse Hub-Height Measurements (Red Quivers)
    quiver(Y_p(Ysel, Zsel), Z_p(Ysel, Zsel), ...
                     U_v(Ysel, Zsel), U_w(Ysel, Zsel), 'r', ...
                     'AutoScaleFactor', 0.75, 'LineWidth', 1.5);
    
    % 4. Rotor Disk Guide (178m Diameter circle centered at 119m hub height)
    th = linspace(0, 2*pi, 100);
    plot(89*cos(th), 89*sin(th) + 119, 'k--', 'LineWidth', 1.2);
    
    % Formatting per tile
    title(titles{idxT}, 'FontSize', fs + 1);
    xlabel('y (m)');
    if idxT == 1, ylabel('z (m)'); else yticklabels([]); end
    axis equal; grid on;
    xlim([-170 170]); ylim([0 300]);
    set(gca, 'FontSize', fs);
end

% Shared Visual Elements
cb = colorbar;
cb.FontSize = fs;

% Export final combined Y-Z slices
strFig = 'WindData_Horizontal_Slices';
print(fullfile(figDir, strFig), '-dpng', '-r300');
print(fullfile(figDir,strFig), '-depsc');