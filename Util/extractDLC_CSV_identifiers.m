function [ratID,vidDate,vidTime,vidNum,boxNum] = extractDLC_CSV_identifiers(csvName)
%
% assumes filenames of the format 'RXXXX_yyyymmdd_HH-MM-SS_YYY_.....csv'
% where XXXX is a 4-digit rat identifier, yyyymmdd is the date, HH-MM-SS is
% the time (hours, minutes, seconds), and YYY is the 3-digit trial number.
% The .... between the formatted information and the file extension is for
% DLC-specific information (training iterations, etc.)
%

box_1_dates = {'20191122','20191123','20191124','20191125'};

isBoxInName = contains(lower(csvName),'box');

if isBoxInName    % box number is not identified in the .csv name
    
    C = textscan(csvName,'R%04d_box%02d_%8c_%8c_%03d');

    ratID = C{1};
    boxNum = C{2};
    vidDate = C{3};
    vidTime = C{4};
    vidNum = C{5};
    
else

    C = textscan(csvName,'R%04d_%8c_%8c_%03d');

    ratID = C{1};
    vidDate = C{2};
    vidTime = C{3};
    vidNum = C{4};
    
    if ismember(box_1_dates,vidDate)
        boxNum = 1;
    else
        boxNum = 99;
    end
    
end

end