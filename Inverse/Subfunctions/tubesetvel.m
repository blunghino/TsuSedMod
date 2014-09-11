function [ws]=tubesetvel(phi,rhos,T, S)
% tubsetvel.m- a function to determine settling velocity in USGS settling
%              tubes from grain size output of sedsize (phi).  Uses Gibbs'
%              settling formula (from excel spreadsheet provided by John
%              Penscil, a contrator who wrote the programs for Mike
%              Torresan).  This spreadsheet is GibbsEquations.xls.  I obtained
%              a copy in 2003.
%
%           [ws]=tubesetvel(phi,rhos,T, S)
%
%   Input:
%       phi- grain size in phi
%       rhos- density of sediment (or sphere) in gm/cm^3
%       T- temperature of water in settling tube, deg. C
%       S- salinity of water in settling tube (added to explore real world)
%
%   Used:
%       g- acceleration due to gravity (cm/s^2)
%       rhof- density of fluid in settling tube (gm/cm^3)
%       kv- kinematic viscosity of fluid in settling tube(m/s^2)
%       dynvisc- dynamic viscosity of fluid in settling tube (poise)
%       r- radius of grain (or sphere) in mm
%       
%   Output:
%       ws- settling velocity of grain (cm/s)
%
%       ** only need to input grain size in phi, will use defaults of
%           rhos=2.65, T=21, S=0
%
%       Need functions KinVisc and sw_dens0
%
%   written 8/1/03 by Bruce Jaffe

g=979.9;          % gravitational acceleration in cm/s^2

if nargin==1;     % use defaults if only phi size is provided
    rhos=2.65;    % quartz density
    T=21.6;         % 21 deg. C water temperature
    S=0;          % fresh water in settling tubes
end

% calculate dynamic viscosity water in settling tube (poise)
kv=KinVisc(T);      % m/s^2
rhof=sw_dens0(S,T); % kg/m^3, 
dynvisc=10*kv*rhof; % dynamic viscosity, converted to poise (dyne-sec/cm^2)

rhof=rhof/1000;     % convert fluid density to gm/cm^3 for use in formula

% reproduce spreadsheet columns and calculate settling velocity
r =(1./(2.^phi))./20;
term= sqrt((9*dynvisc^2)+(g.*r.^2*rhof*(rhos-rhof).*(0.015476+(0.19841.*r))));
ws=(term-(3*dynvisc))./((rhof)*(0.011607+(0.14881.*r)));