function [detS, S]=Ray_s(do, f,z)
%This function is for output ray vector of a single lens system
%Input
%ro: 
%do: Working distance (in mm)
%f: focal length (in mm)
%z: Image location (mm)
%Output
%detS: determinent of the matrix ?
%S: transfer matrix


To=[1, do;0,1];
Lf=[1,0;-(1/f),1];
Ti=[1,z;0,1];
S=Ti*Lf*To;
%Checking determinant for overall matrix
detS=det(S);
