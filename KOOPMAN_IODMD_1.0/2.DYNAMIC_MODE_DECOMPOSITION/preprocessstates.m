function [statesScaled,meansteadystate,scalingfactor] = preprocessstates(states,scalingfactor)

n = size(states, 1) / 3;
U = states(1:n, :);
V = states(n+1:2*n, :);
W = states(2*n+1:end, :);

% 2. Calculate point-by-point magnitude (Result is n x 909)
V_mag_all = sqrt(U.^2 + V.^2 + W.^2);

% 3. Calculate SCALARS from the entire training distribution
% Use (:) to collapse the matrix into a single column
meansteadystate = mean(V_mag_all(:));

if nargin == 1
    % 1. Separate your components (assuming they are stacked row-wise)
    scalingfactor = std(V_mag_all(:));
end

statesScaled = states/scalingfactor;

%find mean of steady state
%assuming stady state is from
% steadystates=states(:,1:5);
% 
% for i=1:size(steadystates,1)
%     meansteadystate(i)=mean(steadystates(i,:));
% end
% 
% meansteadystate=meansteadystate';
% 
% %subtract the steady state dynamics from states
% 
% for l=1:size(states,2)
%     states(:,l)=states(:,l)-meansteadystate;
% end
% 
% % states=detrend(states);
% %scalingfactor=var(var(states));
% scalingfactor=1;
% states=states./scalingfactor;

% states=states.^2;
end

