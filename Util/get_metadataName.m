function metadataName = get_metadataName(csvName,pawPref)

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





metadataName = '';