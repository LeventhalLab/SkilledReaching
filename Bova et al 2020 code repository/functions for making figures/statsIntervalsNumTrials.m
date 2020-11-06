function statsIntervalsNumTrials(numTrials,sumByLaser)

% paired t-tests for each z endpoint interval

avgRat(:,:,1) = sum(numTrials(:,:,1:2),3)/2;
avgRat(:,:,2) = sum(numTrials(:,:,3:12),3)/10;
avgRat(:,:,3) = sum(numTrials(:,:,13:22),3)/10;

for i_sess = 1:2
    for i_int = 1:10
        t1 = avgRat(:,i_int,i_sess);
        t2 = avgRat(:,i_int,i_sess+1);
        [h,p,ci,stats] = ttest(t1,t2);
        ps(i_int,i_sess) = p;
    end 
end 

sumByLaser = sumByLaser;
markStatsIntervals(ps,sumByLaser)

