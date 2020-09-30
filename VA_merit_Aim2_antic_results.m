%%

% x = rand(100,1);

savedir = '/Users/dleventh/Box/Leventhal Lab/Proposals/VA merit/VA Merit_skilled_reaching_spring2020/VA_Merit_SR_spring2020_figs';

linear_color = 'r';
sigmoid_color = 'k';
any_color = 'b';

h_fig = figure(1);
% subplot(1,3,1);


x = [0:0.1:5];

noise_sig = 0.02*randn(1,length(x));
noise_sig2 = 0.02*randn(1,length(x));
x0 = 2.5;
L = 1;
k = 2;   % bigger k --> steeper curve

% x = [0:0.1:5];
% y = max(L ./ (1 + exp(-k*(x-x0))) + noise_sig,0);
% 
% scatter(x,y)
% hold on

k = 7;
y2 = L ./ (1 + exp(-k*(x-x0)));
scatter(x,max(y2+noise_sig,0),'markeredgecolor',sigmoid_color,'markerfacecolor',sigmoid_color)
hold on
plot(x,y2,sigmoid_color)

y3 = 0.2*x;
scatter(x,max(y3+ noise_sig2,0),'marker','s','markeredgecolor',linear_color,'markerfacecolor',linear_color)
plot(x,y3,linear_color)

k = 9;
x0 = 0.3;
y4 = L ./ (1 + exp(-k*(x-x0)));
scatter(x,max(y4+ noise_sig2,0),'marker','^','markeredgecolor',any_color,'markerfacecolor',any_color)
plot(x,y4,any_color)

hold off

set(gcf,'units','inches','position',[1 1 3 3])
set(gca,'ytick',[0,0.5,1],'yticklabel',[],'xtick',[0 5], 'xticklabel',[])
xlabel('DF/F','fontname','helvetica','fontsize',10)
ylabel('z','fontname','helvetica','fontsize',10)

savename = fullfile(savedir, 'graded_results.pdf');
print(savename,'-dpdf')

%%

h_fig2 = figure(2);

x = [1,2,3,4];
xscaled = [0,1,2,5];
y = (xscaled(x)-1) * 3;
y(1) = 0;

n = 10;
noise_std = 0.5;
noise_sig1 = noise_std*randn(1,n);
noise_sig2 = noise_std*randn(1,n);
noise_sig3 = noise_std*randn(1,n);
noise_sig4 = noise_std*randn(1,n);

    
h_bar = bar(x,y);
set(h_bar,'facecolor','r','edgecolor','r')
hold on
scatter(ones(1,n),y(1) + noise_sig1, 'markeredgecolor','k')
scatter(2*ones(1,n),y(2) + noise_sig2, 'markeredgecolor','k')
scatter(3*ones(1,n),y(3) + noise_sig3, 'markeredgecolor','k')
scatter(4*ones(1,n),y(4) + noise_sig4, 'markeredgecolor','k')

set(gca,'ytick',[0,0.5,1],'yticklabel',[],'xtick',[1,2,3,4], 'xticklabel',{'no stim','1x','2x','5x'})
set(gca,'ylim',[-1,y(end)+1],'xlim',[0 5])
xlabel('stim level (multiples of baseline DF/F)','fontname','helvetica','fontsize',10)
ylabel('Dz','fontname','helvetica','fontsize',10)
set(gcf,'units','inches','position',[1 1 3 3])
hold off

savename = fullfile(savedir, 'expt2b_ant_results.pdf');
print(savename,'-dpdf')