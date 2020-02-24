%%
function aim1a_results()

ChR2_striatum.color = 'b';
ChR2_striatum.marker = '^';
ChR2_M1.color = 'b';
ChR2_M1.marker = 's';
EYFP_striatum.color = 'r';
EYFP_striatum.marker = '^';
EYFP_M1.color = 'r';
EYFP_M1.marker = 's';

lineColor = ones(3,1) * 0.5;
laser_alpha = 0.05;

num_rows = 2;

z_limits = [-10 10];

test_days = [1:10];
min_z = 5;
max_x = 10;

plot_sep = 0.4;

z_chr2_str = zeros(length(test_days)+1,1);
z_eyfp_str = zeros(length(test_days)+1,1);
z_chr2_M1 = zeros(length(test_days)+1,1);
z_eyfp_M1 = zeros(length(test_days)+1,1);

i_row = 1;
z_chr2_str(1) = (-min_z-(2*plot_sep)+max_x*exp(-(0-0)/2));
z_chr2_str(2:end) = (-min_z-(2*plot_sep)+max_x*exp(-(test_days)/3));
z_eyfp_str(1) = (-min_z+plot_sep+max_x*exp(-(0-0)/2));
z_eyfp_str(2:end) = (-min_z+plot_sep+max_x*exp(-(ones(length(test_days),1)-1)/2));
% 
z_chr2_M1(1) = (-min_z-plot_sep+max_x*exp(-(0-0)/2));
z_chr2_M1(2:end) = (-min_z-plot_sep+max_x*exp(-(ones(length(test_days),1)-1)/2));
z_eyfp_M1(1) = (-min_z+max_x*exp(-(0-0)/2));
z_eyfp_M1(2:end) = (-min_z+max_x*exp(-(ones(length(test_days),1)-1)/2));

figure(1)

make_session_plot(i_row, test_days, z_chr2_str, z_eyfp_str, z_chr2_M1, z_eyfp_M1, ChR2_striatum, EYFP_striatum, ChR2_M1, EYFP_M1, num_rows, z_limits,laser_alpha)

% 5-on, 5-off
z_chr2_str_on_off = zeros(1,10);
z_chr2_M1_on_off = zeros(1,10);
z_eyfp_str_on_off = zeros(1,10);
z_eyfp_M1_on_off = zeros(1,10);

z_chr2_str_on_off(1:5) = z_chr2_str(end);
z_chr2_M1_on_off(1:5) = z_chr2_M1(end);
z_eyfp_str_on_off(1:5) = z_eyfp_str(end);
z_eyfp_M1_on_off(1:5) = z_eyfp_M1(end);

z_chr2_str_on_off(6:10) = z_chr2_str(1);
z_chr2_M1_on_off(6:10) = z_chr2_M1(1);
z_eyfp_str_on_off(6:10) = z_eyfp_str(1);
z_eyfp_M1_on_off(6:10) = z_eyfp_M1(1);

make_5_on_off_plot(i_row, z_chr2_str_on_off, z_eyfp_str_on_off, z_chr2_M1_on_off, z_eyfp_M1_on_off, ChR2_striatum, EYFP_striatum, ChR2_M1, EYFP_M1, num_rows, lineColor, z_limits,laser_alpha)



%% row 2 - M1 for plasticity, SNc to make it happen

i_row = 2;
z_chr2_str(1) = (-min_z-(2*plot_sep)+max_x*exp(-(0-0)/2));
z_chr2_str(2:end) = (-min_z-(2*plot_sep)+max_x*exp(-(ones(length(test_days),1)-1)/3));
z_eyfp_str(1) = (-min_z+plot_sep+max_x*exp(-(0-0)/2));
z_eyfp_str(2:end) = (-min_z+plot_sep+max_x*exp(-(ones(length(test_days),1)-1)/2));
% 
z_chr2_M1(1) = (-min_z-plot_sep+max_x*exp(-(0-0)/2));
z_chr2_M1(2:end) = (-min_z-plot_sep+max_x*exp(-(ones(length(test_days),1)-1)/2));
z_eyfp_M1(1) = (-min_z+max_x*exp(-(0-0)/2));
z_eyfp_M1(2:end) = (-min_z+max_x*exp(-(ones(length(test_days),1)-1)/2));

make_session_plot(i_row, test_days, z_chr2_str, z_eyfp_str, z_chr2_M1, z_eyfp_M1, ChR2_striatum, EYFP_striatum, ChR2_M1, EYFP_M1, num_rows, z_limits,laser_alpha)

z_chr2_str_on_off = zeros(1,10);
z_chr2_M1_on_off = zeros(1,10);
z_eyfp_str_on_off = zeros(1,10);
z_eyfp_M1_on_off = zeros(1,10);

z_chr2_str_on_off(1:5) = z_chr2_str(end);
z_chr2_M1_on_off(1:5) = -5;
z_eyfp_str_on_off(1:5) = z_eyfp_str(end);
z_eyfp_M1_on_off(1:5) = z_eyfp_M1(end);

z_chr2_str_on_off(6:10) = z_chr2_str(1);
z_chr2_M1_on_off(6:10) = z_chr2_M1(1);
z_eyfp_str_on_off(6:10) = z_eyfp_str(1);
z_eyfp_M1_on_off(6:10) = z_eyfp_M1(1);

make_5_on_off_plot(i_row, z_chr2_str_on_off, z_eyfp_str_on_off, z_chr2_M1_on_off, z_eyfp_M1_on_off, ChR2_striatum, EYFP_striatum, ChR2_M1, EYFP_M1, num_rows, lineColor, z_limits,laser_alpha)

subplot(num_rows,2,num_rows*2-1)
legend('dSTR, ChR2', 'dSTR, EYFP', 'M1, ChR2', 'M1, EYFP')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function make_session_plot(i_row, test_days, z_chr2_str, z_eyfp_str, z_chr2_M1, z_eyfp_M1, ChR2_striatum, EYFP_striatum, ChR2_M1, EYFP_M1, num_rows, z_limits,laser_alpha)

subplot_p = (i_row-1) * 2 + 1;

subplot(num_rows,2,subplot_p)

scatter([-0.5,test_days],z_chr2_str,'marker',ChR2_striatum.marker,'markeredgecolor',ChR2_striatum.color,'markerfacecolor',ChR2_striatum.color)
hold on
scatter([-0.5,test_days],z_eyfp_str,'marker',EYFP_striatum.marker,'markeredgecolor',EYFP_striatum.color)
scatter([-0.5,test_days],z_chr2_M1,'marker',ChR2_M1.marker,'markeredgecolor',ChR2_M1.color,'markerfacecolor',ChR2_M1.color)
scatter([-0.5,test_days],z_eyfp_M1,'marker',EYFP_M1.marker,'markeredgecolor',EYFP_M1.color)

line([-1,10.5],[0,0],'color','k');

hold off

set(gca,'ydir','reverse','ylim',z_limits,'xlim',[-1,10.5]);

h_patch = patch([0.5,0.5,10.5,10.5],[z_limits(1),z_limits(2),z_limits(2),z_limits(1)],'b',...
    'facealpha',laser_alpha,'edgealpha',laser_alpha);

xticklabels = [1,10];
if i_row < num_rows
    set(gca,'xticklabel',[])
else
    set(gca,'xticklabel',xticklabels);
    xlabel('session number','fontname','helvetica','fontsize',10)
end
set(gca,'xtick',[1,10]);
set(gca,'ytick',[-10:10:10],'yticklabel',[-10:10:10],'fontname','helvetica','fontsize',10);
ylabel('reach extent (mm)','fontname','helvetica','fontsize',10)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function make_5_on_off_plot(i_row, z_chr2_str_on_off, z_eyfp_str_on_off, z_chr2_M1_on_off, z_eyfp_M1_on_off, ChR2_striatum, EYFP_striatum, ChR2_M1, EYFP_M1, num_rows, lineColor, z_limits,laser_alpha)

subplot_p = (i_row-1) * 2 + 2;

subplot(num_rows,2,subplot_p)

plot(1:10,z_chr2_str_on_off,'marker',ChR2_striatum.marker,'markeredgecolor',ChR2_striatum.color,'markerfacecolor',ChR2_striatum.color,'color',lineColor)
hold on
plot(1:10,z_eyfp_str_on_off,'marker',EYFP_striatum.marker,'markeredgecolor',EYFP_striatum.color,'color',lineColor)
plot(1:10,z_chr2_M1_on_off,'marker',ChR2_M1.marker,'markeredgecolor',ChR2_M1.color,'markerfacecolor',ChR2_M1.color,'color',lineColor)
plot(1:10,z_eyfp_M1_on_off,'marker',EYFP_M1.marker,'markeredgecolor',EYFP_M1.color,'color',lineColor)

scatter(11:20,z_chr2_str_on_off,'marker',ChR2_striatum.marker,'markeredgecolor',ChR2_striatum.color,'markerfacecolor',ChR2_striatum.color)
scatter(11:20,z_eyfp_str_on_off,'marker',EYFP_striatum.marker,'markeredgecolor',EYFP_striatum.color)
scatter(11:20,z_chr2_M1_on_off,'marker',ChR2_M1.marker,'markeredgecolor',ChR2_M1.color,'markerfacecolor',ChR2_M1.color)
scatter(11:20,z_eyfp_M1_on_off,'marker',EYFP_M1.marker,'markeredgecolor',EYFP_M1.color)
hold off

set(gca,'ydir','reverse','ylim',z_limits);

line([0,20],[0,0],'color','k');
for i_patch = 1 : 2
    h_patch(i_patch) = patch((i_patch-1)*10+[0.5,0.5,5.5,5.5],[z_limits(1),z_limits(2),z_limits(2),z_limits(1)],'b',...
        'facealpha',laser_alpha,'edgealpha',laser_alpha);
end

xticklabels = [1,5,1,5,1,5,1,5];

if i_row < num_rows
    set(gca,'xticklabel',[])
else
    set(gca,'xticklabel',xticklabels);
    xlabel('trial in block','fontname','helvetica','fontsize',10)
end
set(gca,'xtick',[1,5,6,10,11,15,16,20]);
set(gca,'ytick',[-10:5:10],'yticklabel',[],'fontname','helvetica','fontsize',10);
end