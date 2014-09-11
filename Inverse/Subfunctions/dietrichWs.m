function [ws]=dietrichWs(T,D,rhos,rhow,Cs,csf,P)
% dietrichWs.m-  a function to calculate settling velocity from Dietrich'82
%
%  Reference: Dietrich, W. E., 1982, Settling velocity of natural
%  particles. Water Resources Research, v. 18, no. 6, pp. 1615-1626.
%
% function [ws]=dietrichWs(T,D,rhos,rhow,Cs,csf,P)
%
%   Input
%       T- temperature of fluid in deg. C
%       D- grain size in mm
%       rhos- density of sediment in gm/cm^3
%       rhow- density of water in gm/cm^3
%       Cs- volume concentration of sediment
%       csf- Corey shape factor, usually taken as 0.7
%       P- roundness of grains, usaully taken as 3.5
%
%   Used
%       g- acceleration due to gravity, 980 cm/sec^2
%       k- 1/von karmen's constant, 2.5
%
%   Calculated
%       mu- dynamic viscosity of water (poise)
%       musubs- dynamic viscosity of fluid (poise)
%       rhof- density of fluid in gm/cm^3
%       nu- kinematic viscosity of fluid (poise)
%       dstar- dimensionless particle size
%       wstar- dimensionless settling velocity
%
%   Output
%       ws- settling velocity (cm/s)
%
%
%   ** need function KinVisc
%
%   written by BEJ 8/6/03


g=980;  % acceleration due to gravity, cm/sec^2
k=2.5;  
if nargin==5  % if csf and P are not set, use defaults
    csf=0.7;  % set Corey shape factor of grains to default value
    P=3.5;    % set roundness of grains to default value
end
% calculate mu for the water temperature (Guy's code, not used)
%v=[1.7313,1.6728,1.6191,1.5674,1.5188, ...
%1.4728,1.4284,1.3860,1.3462,1.3077, ...
%1.2713,1.2363,1.2028,1.1709,1.1404, ...
%1.1111,1.0828,1.0559,1.0299,1.0050, ...
%.9810,.9579,.9358,.9142,.8937,.8737, ...
%.8545,.8369,.8180,.8007];

%delt=T-floor(T);
%if(T<=1)
%    mu=0.0608*T+1.7921;
%else
%    mu=(v(floor(T))-v(floor(T)+1))*-delt+v(floor(T));
%end
%mu=mu/100;

mu=KinVisc(T)*rhow*10^4;         % convert kinematic viscosity in m2/s to dynamic viscosity in poise 
% calculate dynamic viscosity for water and sediment
musubs=mu*(1+k*Cs);

% calculate fluid density
rhof=rhow+(rhos-rhow)*Cs;

% calculate nu for the sediment conentration
nu=musubs/rhof;


% calculate settling velocity, converts grain size from mm to cm
dstar=(rhos-rhof)*g*(D/10)^3/(rhof*nu^2);              % eq. 6, Dietrich '82 (D82), converting size from mm to cm
dstarl=log10(dstar);
    r1 = -3.76715 + 1.92944*dstarl-0.09815*dstarl^2-0.00575 ...      % fitted equation for size and density effects, eq. 9 D82
        *dstarl^3+0.00056*dstarl^4;
    omc=1.-csf;
    r2 = log10(1-omc/0.85)-omc^2.3*tanh(dstarl-4.6)+0.3*(0.5-csf)... % fitted equation for shape effects. eq. 16 D82
        *omc^2*(dstarl-4.6);
    r3 = (0.65-(csf/2.83)*tanh(dstarl-4.6))^(1+(3.5-P)/2.5);         % fitted equation for roundness effects, eq. 18 D82
         wstar = r3*10^(r1+r2);                                       % eq. 19, D82
         ws= ((rhos-rhof)*g*nu*wstar/rhof)^(1/3);                     % rearranged eq. 5 from D82


