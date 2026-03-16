function f = MPC_progress(part,subpart,f,si,r)
% Dummy version of MPC_progress to overvrite file in folder OTHER

%% Initifalize f
if nargin < 3 || part > 6 || isempty(f)
    % f = ''; % default if
    return;
end

