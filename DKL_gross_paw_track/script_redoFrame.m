%%
frameNum = 177;
iView = 2;

q = points2d{iView,frameNum};

figure(1);
hold off
plot(q(:,1),q(:,2),'marker','.','linestyle','none')
set(gca,'ydir','reverse')

%%
% filtIdx = 2;
idx1 = q(:,1) > 432;
idx2 = q(:,2) < 648;

idx = idx1 & idx2;

figure(1);
hold on
plot(q(~idx,1),q(~idx,2),'marker','.','linestyle','none')

%%
q2 = q(~idx,:);
figure(1);
hold on
plot(q2(:,1),q2(:,2),'marker','.','linestyle','none')
%%

points2d{iView,frameNum} = q2;
figure(1);
        hold on
plot(points2d{iView,frameNum}(:,1),points2d{iView,frameNum}(:,2),'marker','.','linestyle','none')