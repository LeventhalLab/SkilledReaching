function sessions_analyzed = matchSessionsToDates(sessionTable,analysis_dates)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

num_analysis_dates = length(analysis_dates);

valid_date_idx = false(size(sessionTable,1),1);

session_table_dates = sessionTable.date;
for i_date = 1 : num_analysis_dates
    
    valid_date_idx = valid_date_idx | (session_table_dates == analysis_dates(i_date));
    
end

sessions_analyzed = sessionTable(valid_date_idx,:);

end

