function M = skewSymm(a)
%
% usage:
%
% function to create the skew symmetric matrix M given the 3-element vector
% a
%
% INPUTS:
%   a - a 3-element vector
%
% OUTPUTS: 
%   M - the skew-symmetric matrix

M = [ 0000 -a(3)  a(2)
      a(3)  0000 -a(1)
     -a(2)  a(1)  0000];