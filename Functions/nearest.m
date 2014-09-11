function [NearestValue] = nearest(Numbers,PinPoints,method)
% NEAREST Find nearest values to the pin points provided.
%
%   Example: If a = 0:0.01:1; b = sin(2*a*pi); plot(a,b)
%
%            then nearest(b,[-0.5 0 0.25 2]) is [-0.4818 0 0.2487 1.0000].
%
%   See also FIND.

%   Copyright (c) 2000- by Heekwan Lee (heekwan.lee@reading.ac.uk)
%   $Revision: 1.1 $  $Date: 2000/04/16 16:17:18 $


if nargin < 2
   NearestValue = [];
   return
end


Numbers = real(Numbers);
Pins = length(PinPoints);

Max = max(Numbers);
Min = min(Numbers);

for iPin = 1:Pins
   %Identify nearest value(s)
   if PinPoints(iPin) > Max
      tempVals = Max;
   elseif PinPoints(iPin) < Min
      tempVals = Min; 
   else
      nul = abs(Numbers - PinPoints(iPin));
      iValue = find(nul==min(nul));
      tempVals = Numbers(iValue);  
   end

   if length(tempVals)>1
       if strcmpi(method,'max')
           tempVals=max(tempVals);
       elseif strcmpi(method,'min')
           tempVals=min(tempVals);
       elseif strcmpi(method,'mean')
           tempVals=mean(tempVals);
       else
           Display('METHOD==ALL')
           tempVals=unique(tempVals);
       end
   end
 %Find location of nearest value(s) 
   NearestValue(iPin,:)=tempVals;
   
end
   
   

