function pawData = load_pawTrackData_DL(processedDir, trialNum)
%
% function to read left, center, right paw coordinates from Titus'
% directories

pawData = [];

cd(processedDir);

pawTrackFile = dir(['*' trialNum '_DLtrack.mat']);

if isempty(pawTrackFile)
    return;
end

pawData = load(pawTrackFile.name);
