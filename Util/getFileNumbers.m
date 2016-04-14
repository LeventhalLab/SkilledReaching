function fileNumbers = getFileNumbers(fileDir, file_ext, num_separator)
%
%
% INPUTS:
%   fileDir - directory in which to look for files
%   file_ext - extension of files to look for
%   num_separator - character separator between the end of the base file
%       name and the file number (usually '_' or '-')
%
% OUTPUTS:
%   fileNumbers - vector containing the file numbers


curDir = pwd;

cd(fileDir);

% find all files with the appropriate extension
if strcmp(file_ext(1),'.')
    testString = ['*' file_ext];
    ext_length = length(file_ext);
else
    testString = ['*.' file_ext];
    ext_length = length(file_ext) + 1;
end

file_list = dir(testString);

fileNumbers = nan(1,length(file_list));

for i_file = 1 : length(file_list)
    
    fname = file_list(i_file).name;
    if strcmp(fname(1:2),'._'); continue; end
    
    nameLen = length(fname);
    sep_idx = strfind(fname, num_separator);
    
    num_lim = [max(sep_idx)+1, nameLen-ext_length];
    
    fileNumbers(i_file) = str2num(fname(num_lim(1):num_lim(2)));
    
end

fileNumbers = fileNumbers(~isnan(fileNumbers));

cd(curDir);    % go back to original directory