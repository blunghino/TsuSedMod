
function [val]=macwilliams(H,k,n,zo)
%MCWILLIAMS Conversion between Manning's n and Hydrodynamic roughness
% Set n or zo to zero if this is what is being calculated
% [n,zo]=mcwilliams(H,k,n,zo)
% n=Manning's n
% zo=Hydrodynamic roughness [m]
% H=water depth [m]
% k=Van Karmen's constant (default=0.41)
% g=9.81 [m/s^2]

% Equations from Michael McWilliam's Unpublished Ph.D dissertation
% Lambertw function was taken from Pascal Getreuer 2005-2006 with modified by Didier Clamond, 2005

if n==0 
    val=(((H^(1/6))*k)/(sqrt(9.81)))*((H-zo)/(H*log(H/zo)-H+zo));
elseif zo==0
    temp=(-(n*9.81+k*(H^(1/6))*sqrt(9.81))/(H*n*9.81))*exp(-(n*9.81-n*9.81*log(H)+k*(H^(1/6))*sqrt(9.81))/(n*9.81));
    w=lambertw(temp);
    val=exp(-(1/(n*9.81))*(w*n*9.81+n*9.81-n*9.81*log(H)+k*(H^(1/6))*sqrt(9.81)));
else
    error('Set either n or zo to zero')
end
function w = lambertw(b,z)
%LAMBERTW  Lambert W-Function.
%   W = LAMBERTW(Z) computes the principal value of the Lambert 
%   W-Function, the solution of Z = W*exp(W).  Z may be a 
%   complex scalar or array.  For real Z, the result is real on
%   the principal branch for Z >= -1/e.
%
%   W = LAMBERTW(B,Z) specifies which branch of the Lambert 
%   W-Function to compute.  If Z is an array, B may be either an
%   integer array of the same size as Z or an integer scalar.
%   If Z is a scalar, B may be an array of any size.
%
%   The algorithm uses series approximations as initializations
%   and Halley's method as developed in Corless, Gonnet, Hare,
%   Jeffrey, Knuth, "On the Lambert W Function", Advances in
%   Computational Mathematics, volume 5, 1996, pp. 329-359.

% Pascal Getreuer 2005-2006
% Modified by Didier Clamond, 2005

if nargin == 1
   z = b;
   b = 0;
end

% Use asymptotic expansion w = log(z) - log(log(z)) for most z
tmp = log(z + (z == 0)) + i*b*6.28318530717958648;
w = tmp - log(tmp + (tmp == 0));

% For b = 0, use a series expansion when close to the branch point
k = find(b == 0 & abs(z + 0.3678794411714423216) <= 1.5);
tmp = sqrt(5.43656365691809047*z + 2) - 1 + i*b*6.28318530717958648;
w(k) = tmp(k);

for k = 1:36
   % Converge with Halley's iterations, about 5 iterations satisfies
   % the tolerance for most z
   c1 = exp(w);
   c2 = w.*c1 - z;
   w1 = w + (w ~= -1);
   dw = c2./(c1.*w1 - ((w + 2).*c2./(2*w1)));
   w = w - dw;

   if all(abs(dw) < 0.7e-16*(2+abs(w)))
      break;
   end
end

% Specially handle z = 0
w(b ~= 0 & z == 0) = -inf;
