clc; clear; close all;



% Define the four value ranges based on your input
range1 = 1:2;          % [1, 2]
range2 = 5:15;         % [5, 6, ..., 15]
range3 = 40:60;        % [40, 41, ..., 60]
range4 = 68:72;        % [68, 69, ..., 72]
range5 = 3:73; 

% Use ndgrid to create a 4-dimensional grid of all possible points
[A, B, C, D] = ndgrid(range1, range2, range3, range4);
%[A, B, C] = ndgrid(range1, range5, range4);


% Concatenate the flattened grids into a single matrix
% Each row represents one unique combination
combinationsMatrix = [A(:), B(:), C(:), D(:)];
%combinationsMatrix = [A(:), B(:), C(:)];

% Sort the rows to ensure they follow a strict numerical order 
% (First by col 1, then col 2, etc.)
combinationsMatrix = sortrows(combinationsMatrix);

% --- Output Results ---
fprintf('Generated a matrix with %d unique combinations.\n', size(combinationsMatrix, 1));

% % Display the first 15 rows to verify
disp('Preview of the first 15 combinations:');
disp(combinationsMatrix(1:15, :));

%  1     5    41    69

VAF_P2 = nan(1,length(combinationsMatrix));
for idx = 1: length(combinationsMatrix)
    Xsel = combinationsMatrix(idx, :);
    VAF_P2(idx) = getVAFforDifferentPositions(Xsel);
    save(['VAF_P2_M',num2str(size(combinationsMatrix,2)),'.mat'],'VAF_P2');
end

% Results 3 turbines