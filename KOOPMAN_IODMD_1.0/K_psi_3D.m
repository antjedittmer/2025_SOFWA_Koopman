function [p, stateName, structPrev] = K_psi_3D(in1, noStates, structPrev, PolyLiftingFunction)
% K_PSI_3D Lifts 2D input states into a higher-dimensional nonlinear feature space.
%
% USAGE:
%   [p, stateName, structPrev] = K_psi_3D(in1, noStates, structPrev, PolyLiftingFunction)
%
% INPUTS:
%   in1        - [2 x N] Matrix of raw inputs (Ur1 and Ur2)
%   noStates   - Integer, number of lifted states to return
%   structPrev - Struct containing historical values for recursive calculations
%   PolyLiftingFunction - Boolean, toggles between simple polynomial and complex lifting
%
% OUTPUTS:
%   p          - The lifted state matrix (Xaug2)
%   stateName  - Semicolon-separated string of the active state names
%   structPrev - Updated history struct for the next time step

    %% 1. Initialize or Load State History
    % If only one argument is passed, initialize with default zero values
    if nargin == 1
        PolyLiftingFunction = 0;
        noStates = 6;
        Ur1_prev1 = 0; Ur2_prev1 = 0;
        dUr1_prev1 = 0; dUr2_prev1 = 0;
        M1 = 0; M2 = 0; % Moving means
        k = 0;          % Time step counter
    else
        % Retrieve previous values from the storage struct
        Ur1_prev1 = structPrev.Ur1_prev1;
        Ur2_prev1 = structPrev.Ur2_prev1;
        dUr1_prev1 = structPrev.dUr1_prev1;
        dUr2_prev1 = structPrev.dUr2_prev1;
        M1 = structPrev.M1;
        M2 = structPrev.M2;
        k = structPrev.k;
    end

    % Extract primary signals
    Ur1 = in1(1,:);
    Ur2 = in1(2,:);

    %% 2. Compute Derivatives and Statistical Features
    % Calculate 1st and 2nd order differences (numerical derivatives)
    Ur1_prev = [Ur1_prev1, Ur1(1,1:end-1)]; 
    Ur2_prev = [Ur2_prev1, Ur2(1,1:end-1)];
    
    dUr1 = Ur1 - Ur1_prev; 
    dUr2 = Ur2 - Ur2_prev;
    
    dUr1_prev = [dUr1_prev1, dUr1(1,1:end-1)];
    dUr2_prev = [dUr2_prev1, dUr2(1,1:end-1)];
    
    ddUr1 = dUr1 - dUr1_prev; % Second difference
    ddUr2 = dUr2 - dUr2_prev;
    
    % Squared differences (Energy-related features)
    dUr1sqr = Ur1.^2 - Ur1_prev.^2;
    dUr2sqr = Ur2.^2 - Ur2_prev.^2;

    % Recursive Moving Mean calculation (window size n = 25)
    n = 25;
    lVec = min(n, k);
    if lVec > 0
        M1 = ((lVec-1)/lVec) * M1 + (1/lVec) * Ur1_prev;
        M2 = ((lVec-1)/lVec) * M2 + (1/lVec) * Ur2_prev;
    end

    % Deviation from the mean (fluctuation components)
    DUr1 = Ur1 - M1;
    DUr2 = Ur2 - M2;

    %% 3. Construct Lifted State Vector (Mapping to Feature Space)
    if PolyLiftingFunction
        % Option A: Pure Polynomial Lifting (Up to 6th order)
        Xaug2 = [Ur1; Ur2; Ur1.^2; Ur2.^2; Ur1.^3; Ur2.^3; ...
                 Ur1.^4; Ur2.^4; Ur1.^5; Ur2.^5; Ur1.^6; Ur2.^6];
             
        stateName = 'Ur1;Ur2;Ur1.^2;Ur2.^2;Ur1.^3;Ur2.^3;Ur1.^4;Ur2.^4;Ur1.^5;Ur2.^5;Ur1.^6;Ur2.^6';
    else
        % Option B: Physics-Informed/Complex Lifting
        % Combines raw states, deviations, means, and higher-order interactions
        XaugAll = [Ur1; Ur2; Ur1.^2; Ur2.^2; Ur1.^3; Ur2.^3; ... % 1-6: Polynomials
                   DUr1; DUr2; DUr1.^2; DUr2.^2; M1; M2; ...      % 7-12: Difference mean value, mean value
                   DUr1.*Ur1; DUr2.*Ur2; ...                     % 13-14: Coupling
                   DUr1.^3; DUr2.^3; ...                         % 15-16: Nonlinear Deviations
                   DUr1.^2.*Ur1; DUr2.^2.*Ur2; ...               % 17-18: Cross-moments
                   dUr1; dUr2; ddUr1; ddUr2; dUr1sqr; dUr2sqr];  % 19-24: Derivatives
        
        % Trim to requested number of states
        Xaug2 = XaugAll(1:noStates, :);
        
        % Generate descriptive names for the chosen states
        stateNameAll = ['Ur1;Ur2;Ur1.^2;Ur2.^2;Ur1.^3;Ur2.^3;'... 
                        'DUr1;DUr2;DUr1.^2;DUr2.^2;M1;M2;'... 
                        'DUr1Ur1;DUr2Ur2;'...
                        'DUr1.^3;DUr2.^3;'... 
                        'DUr1.^2Ur1;DUr2.^2Ur2;'...
                        'dUr1;dUr2;ddUr1;ddUr2;dUr1sqr;dUr2sqr;'];
        
        stateCell = regexp(stateNameAll, ';', 'split');
        strCellN = sprintf(' %s;', stateCell{1:noStates});
        stateName = strCellN(2:end-1); % Remove leading space and trailing semicolon
    end

    %% 4. Update History for Next Iteration
    structPrev.Ur1_prev1 = Ur1;
    structPrev.Ur2_prev1 = Ur2;
    structPrev.dUr1_prev1 = dUr1;
    structPrev.dUr2_prev1 = dUr2;
    structPrev.M1 = M1;
    structPrev.M2 = M2;
    structPrev.k = k + 1;

    p = Xaug2;
end


%% unused states
% M11 = movmean(Ur1,[25 0]);%movmean(Ur1,500);%(Ur2,500)
% M21 = movmean(Ur2,[25 0]);%(Ur2,500) %

%;dUr1;dUr2;...
%ddUr1;ddUr2;dUr1sqr;dUr2sqr;M1;M2];%;ddUr1sqr;ddUr2sqr];%;dUr1.*Ur2;dUr2.*Ur1;...
%ddUr1.*Ur2;ddUr2.*Ur1];%DUr1.^3.*Ur1;DUr2.^3.*Ur2];
%diff1;diff2;Deterministic(1,:).*diff1.^3;Deterministic(2,:).*diff2.^3;diff1.^3;diff2.^3;Deterministic(1,:).*diff1;...
%Deterministic(2,:).*diff2];%Deterministic(1,:).*Deterministic(2,:)



