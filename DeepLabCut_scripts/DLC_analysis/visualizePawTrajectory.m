function visualizePawTrajectory(pawTrajectory, bodyparts, varargin)
%
%

[mcp_idx,pip_idx,digit_idx,pawdorsum_idx,nose_idx,pellet_idx,otherpaw_idx] = ...
    group_DLC_bodyparts(bodyparts);

% associate colors with specific body parts

 {'leftmcp1'}    {'leftmcp2'}    {'leftmcp3'}    {'leftmcp4'}

  Columns 5 through 8

    {'leftpip1'}    {'leftpip2'}    {'leftpip3'}    {'leftpip4'}

  Columns 9 through 12

    {'leftdigit1'}    {'leftdigit2'}    {'leftdigit3'}    {'leftdigit4'}

  Columns 13 through 16

    {'leftpawdorsum'}    {'nose'}    {'pellet'}    {'rightpaw'}
    
    
figure(1)