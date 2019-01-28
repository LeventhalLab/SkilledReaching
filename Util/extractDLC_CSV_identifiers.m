function [ratID,vidDate,vidTime,vidNum] = extractDLC_CSV_identifiers(csvName)

C = textscan(csvName,'R%04d_%8c_%8c_%03d');

ratID = C{1};
vidDate = C{2};
vidTime = C{3};
vidNum = C{4};