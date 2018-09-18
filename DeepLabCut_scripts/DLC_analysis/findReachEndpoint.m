function [endpts,frameIdx] = findReachEndpoint(pawTrajectory, bodyparts, pawPref)

[mcpIdx,pipIdx,digIdx,pawDorsumIdx] = findReachingPawParts(bodyparts,pawPref);


% find the first local minimum in the z-dimension after reach onset
z_coords = squeeze(pawTrajectory(:,3,:));
z_smooth = smoothdata(z_coords,1,'movmean',3);
localMins = islocalmin(z_smooth, 1);

x = 1:size(z_smooth,1);
for bp_idx = 1 : 8

% plot(x,z_smooth(:,bp_idx),x(localMins(:,bp_idx)),z_smooth(localMins(:,bp_idx),bp_idx),'r*')
plot(x,z_smooth(:,bp_idx))
set(gca,'ylim',[150 200],'xlim',[300 350]);

hold on
end
end