function [mcpAngle,pipAngle,digitAngle,pawAngle] = determineDirectPawOrientation(direct_pts,direct_bp,invalid_direct,pawPref)
%
% function to determine the angle of the paw in the direct view 
%
% INPUTS
%   direct_pts - num bodyparts x numFrames x 2 array containing (x,y)
%       coordinates of bodyparts in the direct vie
%   direct_bp - cell array containing the bodypart labels corresponding to
%       direct_pts
%   direct_p - num bodyparts x numFrames containing certainty values output
%       by DLC
%   pawPref - 'left' or 'right' indicating the preferred reaching paw
%
% OUTPUTS
%   mcpAngle, pipAngle, digitAngle - angle in radians in the direct view of
%       the paw. pi (or -pi) is horizontal; pi/2 is vertical
%

[mcpIdx,pipIdx,digIdx,~] = findReachingPawParts(direct_bp,pawPref);

% calculate paw orientation at each time point based on mcp, pip, and digit
% markers
numFrames = size(direct_pts,2);
mcpAngle = NaN(numFrames,1);
pipAngle = NaN(numFrames,1);
digitAngle = NaN(numFrames,1);
pawAngle = NaN(numFrames,1);

farthestMCPidx = NaN(numFrames,2);
farthestPIPidx = NaN(numFrames,2);
farthestDIGidx = NaN(numFrames,2);
for iFrame = 1 : numFrames
    
    % find valid mcp points in this frame, if there are any
    farthestMCPidx(iFrame,:) = findFarthestDigits(mcpIdx,~invalid_direct(:,iFrame));
    if all(farthestMCPidx(iFrame,:) > 0)
        MCPpts = squeeze(direct_pts(farthestMCPidx(iFrame,:),iFrame,:));
        MCPpts = flipud(MCPpts);   % to make the angle point the easier-to-interpret direction
        
        % need to keep in mind that angles will be different for right and
        % left paws
        mcpAngle(iFrame) = pointsAngle(MCPpts);
    end
    
    farthestPIPidx(iFrame,:) = findFarthestDigits(pipIdx,~invalid_direct(:,iFrame));
    if all(farthestPIPidx(iFrame,:) > 0)
        PIPpts = squeeze(direct_pts(farthestPIPidx(iFrame,:),iFrame,:));
        PIPpts = flipud(PIPpts);   % to make the angle point the easier-to-interpret direction
        
        % need to keep in mind that angles will be different for right and
        % left paws
        pipAngle(iFrame) = pointsAngle(PIPpts);
    end
        
    farthestDIGidx(iFrame,:) = findFarthestDigits(digIdx,~invalid_direct(:,iFrame));
    if all(farthestDIGidx(iFrame,:) > 0)
        DIGpts = squeeze(direct_pts(farthestDIGidx(iFrame,:),iFrame,:));
        DIGpts = flipud(DIGpts);   % to make the angle point the easier-to-interpret direction
        % need to keep in mind that angles will be different for right and
        % left paws
        digitAngle(iFrame) = pointsAngle(DIGpts);
    end
    
    if diff(farthestDIGidx(iFrame,:)) == 3   % valid points for the first and fourth digits
        pawAngle(iFrame) = digitAngle(iFrame);
    elseif diff(farthestPIPidx(iFrame,:)) == 3
        pawAngle(iFrame) = pipAngle(iFrame);
    elseif diff(farthestMCPidx(iFrame,:)) == 3
        pawAngle(iFrame) = mcpAngle(iFrame);
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ptsIdx = findFarthestDigits(digitIdx,validPoints)
%
% INPUTS:
%   digIdx = indices of digits in the bodyparts array in order
%   validPoints = boolean vector indicating which bodyparts were reliably
%       identified (logical NOT of invalid_direct)

ptsIdx = zeros(1,2);
validDigIdx = validPoints(digitIdx);

if sum(validDigIdx) < 2
    % not enough points to determine an angle
    ptsIdx = [0,0];
    return
end

ptsIdx(1) = digitIdx(find(validDigIdx,1,'first'));
ptsIdx(2) = digitIdx(find(validDigIdx,1,'last'));
    
end