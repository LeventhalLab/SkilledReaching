function pawData = load_pawTrackData_relRGB(processedDir, trialNum)
%
% function to read paw coordinates from DL's tracking algorithms

pawData = [];

cd(processedDir);

pawTrackFile = dir(['*' trialNum '_RGB_rel_track.mat']);

if isempty(pawTrackFile)
    return;
end

pawData = load(pawTrackFile.name);
