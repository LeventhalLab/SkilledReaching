%%
matList = dir('R*.mat');

for ii = 1 : length(matList)
    load(matList(ii).name);
    
    save(matList(ii).name,'pawTrajectory','bodyparts','thisRatInfo');
end