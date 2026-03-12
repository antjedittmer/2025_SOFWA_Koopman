clc; clear; close all;

% Define the four value ranges based on your input
nT = 4; % number of positions
loadMat = 1; % load the mat-file if available

range1 = 1:2;          % [1, 2]
range2 = 5:15;         % [5, 6, ..., 15]
range3 = 40:60;        % [40, 41, ..., 60]
range4 = 68:72;        % [68, 69, ..., 72]
range5 = 3:73; 

% Use ndgrid to create a 4-dimensional grid of all possible points
% Concatenate the flattened grids into a single matrix
% Each row represents one unique combination
if nT == 4
    [A, B, C, D] = ndgrid(range1, range2, range3, range4);
    combinationsMatrix = [A(:), B(:), C(:), D(:)];

elseif nT == 3
    [A, B, C] = ndgrid(range1, range5, range4);
    combinationsMatrix = [A(:), B(:), C(:)];
else
    [A,B] = ndgrid(range1, range4);
    combinationsMatrix = [A(:), B(:)];
    nT = 2;
end
matfilename = ['VAF_P2_M',num2str(nT),'.mat'];

% Sort the rows to ensure they follow a strict numerical order 
% (First by col 1, then col 2, etc.)
combinationsMatrix = sortrows(combinationsMatrix);

% --- Output Results:Display the first 15 rows to verify---
fprintf('Generated a matrix with %d unique combinations.\n', size(combinationsMatrix, 1));

nDisp = min(size(combinationsMatrix, 1),5);
fprintf('Preview of the first %d combinations:\n',nDisp);
disp(combinationsMatrix(1:nDisp, :));

% --- Load the mat file if it exists ---
if exist(matfilename,'file') == 2
   load(matfilename,'VAF_P2');
else
    VAF_P2 = nan(1,length(combinationsMatrix));
    for idx = 1: length(combinationsMatrix)
        Xsel = combinationsMatrix(idx, :);
        VAF_P2(idx) = getVAFforDifferentPositions(Xsel);
        save(matfilename,'VAF_P2');
    end
end

VAF_P2

% --- Print out the maxium
[maxVAF,idxVAF] = max(VAF_P2);
fprintf('Max VAF %2.2f', maxVAF)
combinationsMatrix(idxVAF,:)

idx1 = combinationsMatrix(:,1) == 1;

[maxVAF,idxVAF] = max(VAF_P2(idx1));
fprintf('Max VAF %2.2f', maxVAF)
combinationsMatrix(idxVAF,:)




