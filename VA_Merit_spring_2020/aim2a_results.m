%%

figure(1)
y_lim = [-0.5,6];
x_lim = [0, 11];
yticks = [0,6];
xticks = [1,5,10];

subplot(3,1,1)

x = [1,5,10];

y = [1,3,5];
scatter(x,y)
set(gca,'xlim',x_lim,'ylim',y_lim,'ytick',yticks,'xtick',xticks)


subplot(3,1,2)
y = [1,5,5];
scatter(x,y)
set(gca,'xlim',x_lim,'ylim',y_lim,'ytick',yticks,'xtick',xticks)


subplot(3,1,3)
y = [5,5,5];
scatter(x,y)
set(gca,'xlim',x_lim,'ylim',y_lim,'ytick',yticks,'xtick',xticks)