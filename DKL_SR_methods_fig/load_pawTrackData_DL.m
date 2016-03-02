function pawData = load_pawTrackData_DL(processedDir, trialNum)
%
% function to read paw coordinates from DL's tracking algorithms

pawData = [];

cd(processedDir);

pawTrackFile = dir(['*' trialNum '_DLtrack.mat']);

if isempty(pawTrackFile)
    return;
end

pawData = load(pawTrackFile.name);
