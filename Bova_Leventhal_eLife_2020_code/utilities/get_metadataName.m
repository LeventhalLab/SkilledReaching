function metadataName = get_metadataName(csvName,pawPref)
%
% create standard name of metadata files for cropping
%
% INPUTS
%   csvName - name of the DLC .csv output file
%   pawPref - 'left' or 'right'
%
% OUTPUTS
%   metadataName - name of the metadata file from cropping (so it has
%       cropping coordinates, frame rate, etc) that corresponds to the
%       current .csv DLC output file

direct_idx = strfind(csvName,'direct');
if ~isempty(direct_idx)
    metadataName = [csvName(1:direct_idx-1),'direct_metadata.mat'];
    return
end

if iscategorical(pawPref)
    pawPref = char(pawPref);
end
if strcmpi(pawPref,'right')
    left_idx = strfind(csvName,'left');
    if ~isempty(left_idx)
        metadataName = [csvName(1:left_idx-1),'left_metadata.mat'];
        return
    end
elseif strcmpi(pawPref,'left')
    right_idx = strfind(csvName,'right');
    if ~isempty(right_idx)
        metadataName = [csvName(1:right_idx-1),'right_metadata.mat'];
        return
    end
end

% if couldn't come up with a name, return an empty string
metadataName = '';