function [A,B,C] = constructParallelLine(Q1,Q2,Q0)
%
% INPUTS:
%   Q1 and Q2 are points that define the original line, should be row
%       vectors
%   Q0 is the point through which the new line must pass
%
% OUTPUTS:
%   

m = (Q1(2)-Q2(2)) / (Q1(1)-Q2(1));
b = Q0(2) - m * Q0(1);

A = -m;
B = 1;
C = -b;
