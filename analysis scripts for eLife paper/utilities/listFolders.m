function folders = listFolders(fname)
% find the names of all folders in a directory that match fname
%
% INPUTS
%   fname - string or partial string of folder names to look for
%
% OUTPUTS
%   folders - cell array of folder names that match fname
%
temp = dir(fname);

numFolders = 0;
folders = {};
for ii = 1 : length(temp)
    if isfolder(temp(ii).name)
        numFolders = numFolders + 1;
        folders{numFolders} = temp(ii).name;
    end
end