function statsIntervalsOrient(avgIndivOrient,avgLaserSetting)

avgRat(1,:,:) = nanmean(avgIndivOrient(1:2,:,:),1);
avgRat(2,:,:) = nanmean(avgIndivOrient(3:12,:,:),1);
avgRat(3,:,:) = nanmean(avgIndivOrient(13:22,:,:),1);

for i_sess = 1:2
    for i_int = 1:10
        t1 = avgRat(i_sess,:,i_int);
        t2 = avgRat(i_sess+1,:,i_int);
        [h,p,ci,stats] = ttest(t1,t2);
        ps(i_int,i_sess) = p;
    end 
end 

avgLaserSetting = avgLaserSetting;
kType = 'o';
markStatsIntervalsSucc(ps,avgLaserSetting,kType)