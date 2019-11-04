function plot_single_trajectory(reachData,pd_trajectory,dig_trajectory,frames_of_interest,bodypartColor,h_axes,varargin)

traj_3D_x_lim = [-30 10];
traj_3D_y_lim = [-20 10];
full_traj_z_lim = [-15 50];

scale3D_length = 10;

viewOrientation = [-70,30];

for iarg = 1 : 2 : nargin - 6
    switch lower(varargin{iarg})
        case 'xlims'
            traj_3D_x_lim = varargin{iarg + 1};
        case 'ylims'
            traj_3D_y_lim = varargin{iarg + 1};
        case 'zlims'
            full_traj_z_lim = varargin{iarg + 1};
        case 'vieworientation'
            viewOrientation = varargin{iarg + 1};
    end
end
cur_pd_trajectory = pd_trajectory(reachData.reachStarts(1):reachData.reachEnds(1),:);
% cur_dig_trajectory = dig_trajectory(reachData.reachStarts(1):reachData.reachEnds(1),:,:);
slot_z = reachData.slot_z_wrt_pellet;
    
axes(h_axes)
plot3(cur_pd_trajectory(:,1),cur_pd_trajectory(:,3),cur_pd_trajectory(:,2),'k','linewidth',2);
hold on

for i_frame = 1 : length(frames_of_interest)
    cur_frame = frames_of_interest(i_frame);
    scatter3(pd_trajectory(cur_frame,1),pd_trajectory(cur_frame,3),pd_trajectory(cur_frame,2),15,'marker','o','markerfacecolor','none','markeredgecolor','k');
    lineStart = [pd_trajectory(cur_frame,1),pd_trajectory(cur_frame,3),pd_trajectory(cur_frame,2)];
    for i_dig = 1 : 4
%         toPlot = squeeze(dig_traj_pts(i_frame,i_dig,:));
        toPlot = squeeze(dig_trajectory(cur_frame,:,i_dig));
        lineEnd = toPlot([1,3,2]);
        line([lineStart(1),lineEnd(1)],[lineStart(2),lineEnd(2)],[lineStart(3),lineEnd(3)],'color',bodypartColor.dig(i_dig,:))
        scatter3(toPlot(1),toPlot(3),toPlot(2),15,'marker','o','markerfacecolor','none','markeredgecolor',bodypartColor.dig(i_dig,:));
    end
end

h_patch = patch([traj_3D_x_lim(1),traj_3D_x_lim(1),traj_3D_x_lim(2),traj_3D_x_lim(2)],...
                [slot_z,slot_z,slot_z,slot_z],...
                [traj_3D_y_lim(1),traj_3D_y_lim(2),traj_3D_y_lim(2),traj_3D_y_lim(1)],...
                'k','facealpha',0.1);
            
scatter3(0,0,0,25,'marker','o','markerfacecolor',bodypartColor.pellet,'markeredgecolor','k');

line([traj_3D_x_lim(1),traj_3D_x_lim(1)+scale3D_length],[full_traj_z_lim(2),full_traj_z_lim(2)],[traj_3D_y_lim(1),traj_3D_y_lim(1)],'color','k','linewidth',2)
line([traj_3D_x_lim(1),traj_3D_x_lim(1)],[full_traj_z_lim(2),full_traj_z_lim(2)-scale3D_length],[traj_3D_y_lim(1),traj_3D_y_lim(1)],'color','k','linewidth',2)
line([traj_3D_x_lim(1),traj_3D_x_lim(1)],[full_traj_z_lim(2),full_traj_z_lim(2)],[traj_3D_y_lim(1),traj_3D_y_lim(1)+scale3D_length],'color','k','linewidth',2)

text(traj_3D_x_lim(1)+scale3D_length,full_traj_z_lim(2),traj_3D_y_lim(1),'x','fontname','arial','fontsize',11)
text(traj_3D_x_lim(1),full_traj_z_lim(2),traj_3D_y_lim(1)+scale3D_length,'y','fontname','arial','fontsize',11)
text(traj_3D_x_lim(1),full_traj_z_lim(2)-scale3D_length,traj_3D_y_lim(1),'z','fontname','arial','fontsize',11)
set(gca,'visible','off')

set(gca,'zdir','reverse','xlim',traj_3D_x_lim,'ylim',full_traj_z_lim,'zlim',traj_3D_y_lim,...
    'view',viewOrientation)