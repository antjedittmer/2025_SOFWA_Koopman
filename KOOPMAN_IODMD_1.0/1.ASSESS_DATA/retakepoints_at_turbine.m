function [xxx,yyy,zzz,XX,YY,ZZ,flowreshaped] = retakepoints_at_turbine(flow,x,y,z,Decimate,Xsel,Ysel,Zsel)
% retakepoints

% X direction: 1710 m, 550 points -> 138 points (--> 3points)
% estimated position of turbine 5D = 890m ->  sample point at index 71:
xxx = [];
yyy = [];
zzz = [];
XX = [];
YY = [];
ZZ = [];
if nargin == 5
    Xsel = [1,10,50,70];%1:130;% [1,71];% 
    Ysel = [7:22];% 1:28;% 9:20; %
    Zsel = 10;
end

lxSel = length(Xsel);

% Y direction: 343 m,  111 points -> 28 points (--> 15 points)
% estimated central position of turbine: Ysel = [8:22]
lySel = length(Ysel);

% Z direction: 300m, 99 points -> 25 points (--> 1 points)
% hub height (119m): 
lzSel = length(Zsel);

if isempty(x)== 0

    [xx,yy,zz] = resamplegrid(x,y,z,Decimate);
    X = length(xx);
    Y = length(yy);
    Z = length(zz);

    yyy = yy(1:1:end-1); %yaw to be reviewed later
    xxx = xx(1:1:end-55); %yaw
    zzz = zz(1:1:23); %yaw 23)

    XX = length(xxx);
    YY = length(yyy);
    ZZ = length(zzz);
else
    % first 40 values of x=0 are the first values of flow
    X = 40;
    Y = 20;
    Z = 1;
end
%% YAW
%flowreshaped = nan(XX*YY*ZZ, size(flow,2));
if lzSel >0
    lVec = lxSel*lySel*lzSel;
    ltime = size(flow,2);
    flowreshaped = nan(lVec, size(flow,2));
    lenSel = length(Ysel) * length(Zsel);
    Reconstructedflow = nan(lenSel*length(Xsel),1);
    for t = 1:ltime
        UmeanAbs_sh_u  = reshape(double(flow(:,t)),Y,X,Z);
        for idx = 1: length(Xsel)
            vec = (idx-1)*lenSel + (1:lenSel);
            Reconstructedflow(vec) = UmeanAbs_sh_u(Ysel,Xsel(idx),Zsel); % %UmeanAbs_sh_u(1:end-1,1:end-55,1:23);
        end
        flowreshaped(:,t) = reshape(Reconstructedflow,lVec,1);
    end
else
    lVec = lxSel*lySel;
    ltime = size(flow,2);
    flowreshaped = nan(lVec, size(flow,2));
    for t = 1:ltime
        UmeanAbs_sh_u  = reshape(double(flow(:,t)),Y,X);
        Reconstructedflow = UmeanAbs_sh_u(Ysel,Xsel); % %UmeanAbs_sh_u(1:end-1,1:end-55,1:23);
        flowreshaped(:,t) = reshape(Reconstructedflow,lVec,1);
    end
end

    
%% PITCH
% for t=1:size(flow,2)
%     UmeanAbs_sh_u{t} = reshape(double(flow(:,t)),Y,X,Z);
%     Reconstructedflow=UmeanAbs_sh_u{t}(4:1:end-2,1:1:end-55,1:1:23);
%     flowreshaped(:,t)=reshape(Reconstructedflow,[XX*YY*ZZ,1]);
% end



