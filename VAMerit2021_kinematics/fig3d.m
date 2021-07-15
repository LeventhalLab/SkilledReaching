% fig3d
%%
pelletMarkerColor = 'black';
pelletMarker = 'o';
pelletMarkerSize = 20;

ylims_3d = [-20 10];
xlims_3d = [-10 30];
zlims_3d = [-10 50];

dig_colors = {'r','b','g','c'};
%%
figure
load('/Volumes/Untitled/videos_to_analyze/matlab_readable_dlc/R0382/R0382_20201102e/R0382_20201102_processed_reaches.mat')
load('/Volumes/Untitled/videos_to_analyze/matlab_readable_dlc/R0382/R0382_20201103b/R0382_20201103_processed_reaches.mat')
load('/Volumes/Untitled/videos_to_analyze/matlab_readable_dlc/R0382/R0382_20201104c/R0382_20201104_processed_reaches.mat')


for i_trial = 1 : length(reachData)
   
    
    plot3(reachData(i_trial).segmented_pd_trajectory(:,1),reachData(i_trial).segmented_pd_trajectory(:,3),reachData(i_trial).segmented_pd_trajectory(:,2),'k');
    hold on
    for i_digit = 1 : 4
        toPlot = squeeze(reachData(i_trial).segmented_dig_trajectory(:,:,i_digit));
        plot3(toPlot(:,1),toPlot(:,3),toPlot(:,2),dig_colors{i_digit});
    end
    
end

scatter3(0,0,0,25,'marker','o','markerfacecolor','k','markeredgecolor','k');
    
set(gca,'zdir','reverse','xlim',xlims_3d,'ylim',zlims_3d,'zlim',ylims_3d,'view',[-70,30])
xlabel('x');ylabel('z');zlabel('y')

%%
figure
load('/Volumes/Untitled/videos_to_analyze/matlab_readable_dlc/R0382/R0382_20201216c/R0382_20201216_processed_reaches.mat')
for i_trial = 1 : length(reachData)
   
    if ~isempty(reachData(i_trial).segmented_pd_trajectory)

        plot3(reachData(i_trial).segmented_pd_trajectory(:,1),reachData(i_trial).segmented_pd_trajectory(:,3),reachData(i_trial).segmented_pd_trajectory(:,2),'k');
        hold on
        for i_digit = 1 : 4
            toPlot = squeeze(reachData(i_trial).segmented_dig_trajectory(:,:,i_digit));
            plot3(toPlot(:,1),toPlot(:,3),toPlot(:,2),dig_colors{i_digit});
        end
    end
    
    
end

scatter3(0,0,0,25,'marker','o','markerfacecolor','k','markeredgecolor','k');
    
set(gca,'zdir','reverse','xlim',xlims_3d,'ylim',zlims_3d,'zlim',ylims_3d,'view',[-70,30])

xlabel('x');ylabel('z');zlabel('y')

