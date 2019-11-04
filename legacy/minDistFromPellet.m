function [minDist, frameIdx] = minDistFromPellet(pawTrajectory, bodyparts,pawPref)
%
% find the closest distance between any point on the paw and the sugar
% pellet
%
%
% hard code strings that only occur in bodyparts that are part of the
% reaching paw
reachingPawParts = {'mcp','pip','digit',[pawPref 'dorsum']};

