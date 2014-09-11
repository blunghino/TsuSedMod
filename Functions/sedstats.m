
function [m1,stdev,m3,m4,fwmedian,fwmean,fwsort,fwskew,fwkurt]=sedstats(phi,weight)

% sedstats.m-  a function compute moment measures and Folk and Ward statistics from 
%                 sediment grain size weight % and phi size classes.
%
%   function [m1,stdev,m3,m4,fwmedian,fwmean,fwsort,fwskew,fwkurt]=sedstats(phi,weight)
%
%   Inputs: phi- grain size (phi) for each size class
%           weight- weight (or weight percent, vol concentration) for size classes
%
%   Calculated: phimdpt- phi midpoints used for moment measures for tsunami samples, [-1.125:.25:10 12]
%          
%   Outputs: m1- mean grain size (phi), 1st moment
%            stdev- standard deviation (phi) similar to sorting, is equal to square root of 2nd moment
%            m3- third moment
%            m4- fourth moment
%            fwmedian- Folk and Ward medium grain size (phi), 50th percentile
%            fwmean- Folk and Ward mean grain size (phi)
%            fwsort- Folk and Ward sorting (phi)
%            fwskew- Folk and Ward skewness
%            fwkurt- Folk and Ward Kurtosis
%
%   References:  All formulas form sdsz version 3.3 documentation (dated
%   7/12/89).  Reference given for Folk and Ward statistics is:
%       Chapter 6, Mathematical Treatment of Size Distribution Data, Earle
%       F. McBride, University of Texas at Austin in Carver, R. E., 1971:
%       Procedures in Sedimentary Petrology: John Wiley and Sons, Inc., 653
%       pp.
%
%   written by Bruce Jaffe, 10/2/03

% calculate midpoint of size classes for use in moment measures


% make sure there are minimum of 2 size classes
if length(phi)==1;
    display('Moment measures not valid because there is only 1 size class');
    phi=[phi(1)-eps phi];                 % create a cumulative weight with 0% weight in it to allow calculation
end

mpt1=phi(1)+0.5*(phi(1)-phi(2));
phimdpt=[mpt1;phi(2:length(phi))+0.5*(phi(1:length(phi)-1)-phi(2:length(phi)))];
phimdpt=phimdpt';


% calculate the 1st moment (mean grain size)
m1=sum(phimdpt.*weight)/sum(weight);

dev=phimdpt-m1;

% calculate the standard deviation, similar to sorting, square root of the 2nd moment
var=sum(weight.*(dev.^2))/sum(weight);
stdev=sqrt(var);

% calculate the third moment
m3=sum(weight.*((dev/stdev).^3))/sum(weight);

% calculate the fourth moment
m4=sum(weight.*((dev/stdev).^4))/sum(weight);

% Use phi intervals, not midpoints to calculate Folk and Ward stats- for tsunami samples use [-1:.25:10 14]


cw=100*cumsum(weight)/sum(weight);          % calculate normalized cumulative weight percent

cp=[5 16 25 50 75 84 95];      % cumulative percents used in Folk and Ward statistics

if cw(1) >= 5;
    display('Folk and Ward Statistics suspect because first size class has >= 5% cumulative %')
    cw=[0 cw];                 % create a cumulative weight with 0% weight in it to allow calculation
end

% calculate cumulative percents used in Folk and Ward statistics using
% linear interpolation (could use different interpolation scheme)
for i=1:7;
lp=max(find(cw<cp(i)));
slp=(cp(i)-cw(lp))/(cw(lp+1)-cw(lp));
cumphi(i)=phi(lp)+slp*(phi(lp+1)-phi(lp));
end

% make some names that have meaning!
phi5=cumphi(1);
phi16=cumphi(2);
phi25=cumphi(3);
phi50=cumphi(4);
phi75=cumphi(5);
phi84=cumphi(6);
phi95=cumphi(7);

% calculate Folk and Ward stats
fwmedian=phi50;
fwmean=(phi16+phi50+phi84)/3;
fwsort=(phi84-phi16)/4+(phi95-phi5)/6.6;
fwskew=(phi16+phi84-2*phi50)/(2*(phi50-phi16))...
       +(phi5+phi95-2*phi50)/(2*(phi95-phi5));
fwkurt=(phi95-phi5)/(2.44*(phi75-phi25));