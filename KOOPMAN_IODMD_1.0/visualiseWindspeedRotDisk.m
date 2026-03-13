clc; close all;
clearvars -except QQ_u QQ_v QQ_w x y z;

% Check if wind field data (QQ_u) is already in workspace, otherwise load it
if exist('QQ_u','var') ~= 1 || length(QQ_u) ~= 96600
    parentDir = fileparts(pwd);
    % Path to the flow field identification data set (Yaw Off case)
    filename = 'data/yaw_control/U_data_complete_vec_yaw_off.mat'; 
    load(fullfile(parentDir,filename));
end

figDir = fullfile(pwd,'figDir');
if exist(figDir,'dir') ~= 7
    mkdir(figDir);
end

% --- Grid Setup ---
xLen = length(x); yLen = length(y);  zLen = length(z);
xx = x(1:4:xLen); yy = y(1:4:yLen); zz = z(1:4:zLen); 
X = length(xx); Y = length(yy); Z = length(zz);

% --- Circular Rotor Selection Logic ---
% Lateral indices 7:22 (center ~14.5), Vertical indices 2:17 (center ~9.5/10)
y_center = 14; 
z_center = 10; % Hub height index
R_rotor = 7.5; % Radius in grid units to cover ~178m diameter

[Y_grid, Z_grid] = meshgrid(1:Y, 1:Z);
dist_from_hub = sqrt((Y_grid - y_center).^2 + (Z_grid - z_center).^2);
rotor_mask = dist_from_hub <= R_rotor;

% Define selection indices for visualization
[Zsel_disk, Ysel_disk] = find(rotor_mask); 
Xsel = [1, 70]; % Longitudinal locations for Turbine 1 and 2

% Quiver background grid
Xsel1 = 1:(X-55); 
Ysel1 = 1:(Y-1); 
Zsel1 = 1:23;

[Xm_shs, Ym_shs, Zm] = meshgrid(xx-500, (yy-500), zz);
i = 500; % Time sample index

UmeanAbs_sh_u = reshape(double(QQ_u(:,i)), Y, X, Z);
UmeanAbs_sh_v = reshape(double(QQ_v(:,i)), Y, X, Z);
UmeanAbs_sh_w = reshape(double(QQ_w(:,i)), Y, X, Z);

% --- 1. Hub Height Plan View (X-Y Plane) ---
zH = 10; % Visualize at Hub Height
UmeanAbs_sh_u2D = UmeanAbs_sh_u(:,:,zH);
UmeanAbs_sh_v2D = UmeanAbs_sh_v(:,:,zH);
Vmean_XY = sqrt(UmeanAbs_sh_u2D.^2 + UmeanAbs_sh_v2D.^2);

figure(1);
fs = 13;
contourf(Xm_shs(:,:,zH), Ym_shs(:,:,zH), Vmean_XY); colormap('sky'); hold on;
% Plot background flow vectors
quiver(Xm_shs(Ysel1,Xsel1,zH), Ym_shs(Ysel1,Xsel1,zH), ...
       UmeanAbs_sh_u2D(Ysel1,Xsel1), UmeanAbs_sh_v2D(Ysel1,Xsel1), 'k');
% Plot the rotor points (at hub height only for this view)
Ysel_line = 7:22;
quiver(Xm_shs(Ysel_line, Xsel, zH), Ym_shs(Ysel_line, Xsel, zH), ...
       UmeanAbs_sh_u2D(Ysel_line, Xsel), UmeanAbs_sh_v2D(Ysel_line, Xsel), 'r', 'AutoScaleFactor', 0.2);
xlabel('x (m)'); ylabel('y (m)'); axis equal; colorbar();
title('Plan View at Hub Height');

% --- 2. Rotor Disk Cross-Sections (Y-Z Plane) ---
for idxT = 1:2
    aSel = Xsel(idxT);
    figure(idxT + 1);
    
    % Squeeze out the Y-Z plane at the turbine X-location
    U_plane = squeeze(UmeanAbs_sh_u(:, aSel, :));
    V_plane = squeeze(UmeanAbs_sh_v(:, aSel, :));
    W_plane = squeeze(UmeanAbs_sh_w(:, aSel, :));
    Y_plane = squeeze(Ym_shs(:, aSel, :));
    Z_plane = squeeze(Zm(:, aSel, :));
    V_mag = sqrt(U_plane.^2 + V_plane.^2 + W_plane.^2);
    
    contourf(Y_plane, Z_plane, V_mag); colormap('sky'); hold on;
    
    % Plot background grid vectors
    quiver(Y_plane(Ysel1, Zsel1), Z_plane(Ysel1, Zsel1), ...
           V_plane(Ysel1, Zsel1), W_plane(Ysel1, Zsel1), 'k');
    
    % Plot the CIRCULAR DISK points in Red
    for idx2 = 1: length(Zsel_disk)
        Y_disk = Y_plane(Ysel_disk(idx2), Zsel_disk(idx2));
        Z_disk = Z_plane(Ysel_disk(idx2), Zsel_disk(idx2));
        V_disk = V_plane(Ysel_disk(idx2), Zsel_disk(idx2));
        W_disk = W_plane(Ysel_disk(idx2), Zsel_disk(idx2));

        quiver(Y_disk, Z_disk, V_disk, W_disk, 'r', 'AutoScaleFactor',10);
     end

    
    xlabel('y (m)'); ylabel('z (m)'); axis equal; colorbar();
    legend(['Wind WT', num2str(idxT)], 'Field Data', 'Disk Samples');
    title(['Rotor Disk Coverage - Turbine ', num2str(idxT)]);
end