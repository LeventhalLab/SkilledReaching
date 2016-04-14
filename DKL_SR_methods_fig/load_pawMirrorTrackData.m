function pawData = load_pawMirrorTrackData(processedDir, trialNum)
%
% function to read paw coordinates from DL's tracking algorithms

pawData = [];

cd(processedDir);

trialNumStr = sprintf('%03d',trialNum);
pawTrackFile = dir(['*' trialNumStr '_mirror_track.mat']);

if isempty(pawTrackFile)
    return;
end

pawData = load(pawTrackFile.name);
