function [ratID,vidDate,vidTime,vidNum] = extractDLC_CSV_identifiers(csvName)
%
% assumes filenames of the format 'RXXXX_yyyymmdd_HH-MM-SS_YYY_.....csv'
% where XXXX is a 4-digit rat identifier, yyyymmdd is the date, HH-MM-SS is
% the time (hours, minutes, seconds), and YYY is the 3-digit trial number.
% The .... between the formatted information and the file extension is for
% DLC-specific information (training iterations, etc.)
%
C = textscan(csvName,'R%04d_%8c_%8c_%03d');

ratID = C{1};
vidDate = C{2};
vidTime = C{3};
vidNum = C{4};

end