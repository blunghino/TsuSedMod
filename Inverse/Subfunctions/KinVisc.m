function [kinvisc]=KinVisc(T)%  Kinvisc.m  A program to calculate kinematic viscosity of fresh water given temperature.%  Uses eq. 3.1.4 from Van Rijn, 1993, "Principles of Sediment Transport%  in Rivers, Estuaries, and Coastal Seas."%%   [kinvisc]=KinVisc(T)%%  Input:  T- temperature of fresh water in degrees celsius%%  Output: kinvisc- kinematic viscosity in m^2/s%%%						Written by Bruce Jaffe 1/30/00kinvisc=(1.14-0.031*(T-15)+0.00068*(T-15)^2)*10^-6;