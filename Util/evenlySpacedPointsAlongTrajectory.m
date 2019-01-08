function pts_out = evenlySpacedPointsAlongTrajectory(trajectory, varargin)

num_pts_out = 100;

if nargin == 2
    num_pts_out = varargin{1};
end

pl = pathlength(trajectory);
dist_per_pt = pl / (num_pts_out-1);

pts_out = zeros(num_pts_out,size(trajectory,2));

pts_out(1,:) = trajectory(1,:);
pts_out(num_pts_out,:) = trajectory(end,:);

cur_trajectory_idx = 1;
for i_outPt = 2 : num_pts_out-1
    
    startPt = pts_out(i_outPt-1,:);
    
    dist_along_trajectory = 0;
    while dist_along_trajectory < dist_per_pt
        cur_trajectory_idx = cur_trajectory_idx + 1;
        if dist_along_trajectory == 0
            cur_pt = startPt;
        else
            try
            cur_pt = trajectory(cur_trajectory_idx-1,:);
            catch
                keyboard
            end
        end
        
        prev_dist_along_trajectory = dist_along_trajectory;
        dist_along_trajectory = dist_along_trajectory + ...
            sqrt(sum((trajectory(cur_trajectory_idx,:) - cur_pt).^2,2));
    end
    try
    remaining_dist = dist_per_pt - prev_dist_along_trajectory;
    catch
        keyboard
    end
    
    pts_out(i_outPt,:) = findPointAlongLine(cur_pt,...
                                            trajectory(cur_trajectory_idx,:),...
                                            remaining_dist);
	cur_trajectory_idx = cur_trajectory_idx - 1;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pt = findPointAlongLine(startPt, endPt, ptDist)

fullDist = sqrt(sum((endPt-startPt).^2,2));
fractDist = ptDist/fullDist;

pt = startPt + (endPt-startPt)*fractDist;

end



