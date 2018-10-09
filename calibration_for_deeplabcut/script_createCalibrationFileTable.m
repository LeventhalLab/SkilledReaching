% script_createCalibrationFileTable

calImageDir = '/Volumes/Tbolt_01/Skilled Reaching/calibration_images';
calTableName = fullfile(calImageDir,'calibration_files_summary.csv');

cd(calImageDir);

numCalibrationFiles = 10;

colHeaders = {'date'};
% for ii = 1 : numCalibrationFiles
%     colHeaders{ii+1} = sprintf('image_file%02d',ii);
% end
colHeaders{end + 1} = 'all_points_marked';
colHeaders{end + 1} = 'calibration_verified';

cd(calImageDir);

[imFiles_from_same_date, img_dateList] = groupCalibrationImagesbyDate(imgList);
% [csvFiles_from_same_date, csv_dateList] = group_csv_files_by_date(csvList);
% do we need csv names in the table?

numDates = length(img_dateList);

fid = fopen('calTableName','w');

for ii = 1 : length(colHeaders) - 1
    fprintf(fid,'%s,',colHeaders{ii});
end
fprintf(fid,'%s\n',colHeaders{end});
    
for iDate = 1 : numDates
    
    fprintf(fid,'%s,',img_dateList{iDate});
    
%     for iFile = 1 : length(imFiles_from_same_date{iDate})
%         
%         fprintf(fid,'%s,',imFiles_from_same_date{iDate}{iFile});
%         
%     end
%     % fill in empty columns
%     for ii = 1 : numCalibrationFiles - length(imFiles_from_same_date{iDate})
%         fprintf(fid,',');
%     end
    
    fprintf(fid,',,\n');
    
end

fclose(fid);