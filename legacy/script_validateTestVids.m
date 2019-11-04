% script to check vidoes and figure out which points are valid once the
% network is trained

% parameters for identifying potentially invalid points
maxDistPerFrame = 20;
min_valid_p = 0.8;
min_certain_p = 0.95;

rootPath = fullfile('/Volumes','Tbolt_01','Skilled Reaching');
pawPref = 'left';
tattooed = 'yes';
view = 'direct';

conditionFolder = [pawPref, '_paw_', tattooed, '_tattoo'];
conditionPath = fullfile(rootPath,'deepLabCut_testing_vids',conditionFolder);
viewPath = fullfile(conditionPath,[view '_view']);
resultsPath = fullfile(viewPath,'results');

cd(resultsPath);

csvList = dir('*.csv');
num_valid_csv = 0;
% sometimes there are "._" temp files in a folder that need to be ignored
for i_csv = 1 : length(csvList)
    fname = csvList(i_csv).name;
    if strcmp(fname(1),'.')
        continue;
    end
    num_valid_csv = num_valid_csv + 1;
    if num_valid_csv == 1
        [bodyparts,~,p] = read_DLC_csv(fname);
    end
end

if num_valid_csv == 0
    error(['No valid CSV files found in ' resultsPath]);
end

num_bodyparts = length(bodyparts);
invalidPoints = false(num_bodyparts,size(p,2),num_valid_csv);
dist_moved_per_frame = zeros(num_bodyparts,size(p,2)-1,num_valid_csv);

i_valid_csv = 0;
for i_csv = 1 : length(csvList)
    
    fname = csvList(i_csv).name;
    if strcmp(fname(1),'.')
        continue;
    end
    i_valid_csv = i_valid_csv + 1;
    [bodyparts,parts_loc,p] = read_DLC_csv(fname);
    
    [invalidPoints(:,:,i_valid_csv),dist_moved_per_frame(:,:,i_valid_csv)] = ...
        find_invalid_DLC_points(parts_loc, p, ...
                                'maxdistperframe',maxDistPerFrame, ...
                                'min_valid_p', min_valid_p, ...
                                'min_certain_p', min_certain_p);
                                        
    
end

%%
invalidPointsSummary = sum(invalidPoints,3);
mean_dist_per_frame = nanmean(dist_moved_per_frame,3);

h_validPtsFig = figure(1);
set(gcf,'name','number of invalid points');

h_dist_travelledFig = figure(2);
set(gcf,'name','dist_travelled per frame');
% create subplots
numRows = ceil(sqrt(num_bodyparts));
numCols = ceil(num_bodyparts/numRows);

for i_bodypart = 1 : num_bodyparts
    
    figure(h_validPtsFig)
    subplot(numRows,numCols,i_bodypart);
    bar(invalidPointsSummary(i_bodypart,:))
    title(bodyparts{i_bodypart})
    set(gca,'ylim',[0 num_valid_csv])
    
    figure(h_dist_travelledFig)
    subplot(numRows,numCols,i_bodypart);
    plot(mean_dist_per_frame(i_bodypart,:))
    title(bodyparts{i_bodypart})
%     set(gca,'ylim',[0 num_valid_csv])
    
end
